#
# DNA Shipistrano
#
# = MySQL
#
# Contains helpers for managing a deploy that has a MySQL database attached.
#
# The main crux of this helper to to handle syncing MySQL databases between the
# services. This also includes support for having a 'staging' and 'production'
# database for an application on the same server.
#
# To begin using this helper, configure the database information in your capfile 
# by defining the :mysql_local and :mysql_remote hashes. We recommend using 
# MySQL conf files to prevent storing passwords inside Shipistrano
# 
# set :mysql_local, {
#   :db => 'db_name',
#   :host => 'host',
#   :user => 'mysqluser'
#   :password => 'password'
# }
#
# set :mysql_remote, {
#   :db => 'live_db_name',
#   :config_file => "~/mysql.cnf",
#   :host => 'livehost',
# }
#
# Optionally, if you have both a staging and production database on the same
# server then you can set the remote `:alternative_db` symbol. This will use
# `:db` as the staging database name and `:alternative_db` as the production
# target when running `mysql:push_to_alternative` or 
# `mysql:pull_from_alternative`
#
# set :mysql_remote, {
#   :db => 'live_db_name',
#   :config_file => "~/mysql.cnf",
#   :host => 'livehost',
#   :alternative_db => 'live_db_name_prod'
# }
#
# Most operations here accept cap command line arguments to override the capfile
# settings. For instance, you may want to download the production database to
# your local machine but as a backup (i.e not override your local). To do this
# we can do:
# 
#   cap mysql:download -s alternative=true -s local_db=mysite_production
#
# == Examples
# 
#   // push your mysql database to the server
#   cap mysql:upload
# 
#   // push your mysql database to the 'production' database. This will take
#   // a backup of the current production database and copy from the database
#   // on the remote (i.e you have to `cap mysql:upload` it first). You also 
#   // will need to define the :alternative_name as the example above.
#   cap mysql:push_to_alterative
#
#   // You can also specify the alternative at run time
#   cap mysql:push_to_alternative -s target=db_name
#
# == Variables
#
# - *mysql_local* hash of the local database configuration
# - *mysql_remote* hash of the remote database configuration
#
# == Tasks
#
# - *mysql:upload* uploads the local database to the remote.
# - *mysql:upload_file* uploads a local file containing SQL queries to the 
# machine.
# - *mysql:download* downloads the remote database to local.
# - *mysql:push_to_alterative* copies `:db` on the remote to `:alternative_db`
# - *mysql:console* opens a console on the remote
# - *mysql:cleanupbackups* clean up backups from the remote server. Keeps the
# latest versions.
#
# == Todo
#
# - Support for when mysql server is on a different box to the website. At this
# stage we don't use that setup (closest site has a small REST client on MySQL
# server which gets deployed separately to the main application)
#

namespace :mysql do

  desc <<-DESC
    Open a MySQL console on the remote machine

  DESC
  task :console do
    database = mysql_local[:db]
    exec "ssh #{user}@#{ip} -t 'mysql #{credentials}'"
  end


  desc <<-DESC
    Uploads the local database to the remote machine. Copies the database
    named in the configuration file or by the provided `src` argument. The 
    target database is the one listed in the remote configuration *or* by the
    `target` argument. If you want to use the value defined in `alternative_db`
    for either src, target, use true as the value

      cap mysql:upload // standard local to remote. Uses names in configuration
      cap mysql:upload -s target=site_dev // pushes local to site_dev
      cap mysql:upload -s target=true // pushes to `alternative_db`

  DESC
  task :upload do
    db_src = resolve_database(fetch(:src, false), true)
    db_target = resolve_database(fetch(:target, false), false)

    path = "#{local_cache}/" + output_file(db_src)
    system export(path, db_src, credentials_local)

    upload_sql_to_server(path, db_target, credentials_remote)
  end

  desc <<-DESC
    Upload a file containing SQL queries to the remote machine. Executes on
    the database provided as `name` on the remote. To override, use the 
    `target` argument. Supports both plain text files and Gzipped files.

  DESC
  task :upload_file do
    file = fetch(:file, false)
    target = resolve_database(fetch(:target, false), false)

    if file?
      upload_sql_to_server(file, target, credentials_remote)
    end
  end


  desc <<-DESC
    Downloads database from remote machine, to localhost. Uses the database name
    in the configuration. To override the remote database use the `src` 
    argument. `target` can be used to set the local database to copy it into.

  DESC
  task :download do
    db_src = resolve_database(fetch(:src, false), false)
    db_target = resolve_database(fetch(:target, false), true)

    remote_file = "#{shared_path}/" + output_file(db_src)
    local_file = "#{local_cache}/mysql-" + output_file(db_target)

    run export(remote_file, db_src, credentials_remote)

    system "mkdir -p #{local_cache}"
    system "rsync -rv #{user}@#{ip}:#{remote_file} #{local_file}"
    
    run "rm -rf "+ remote_file

    system import(local_file, db_target, credentials_local)
  end

  desc <<-DESC
    Copies the remote database to the `alternative_db`. To copy the database
    the other way, or between different databases, use the `src` and `target`
    options. Takes a backup of the target and saves an export in 
    shared/mysql/backups.

  DESC
  task :copy_on_remote do
    db_src = resolve_database(fetch(:src, false), false)
    db_target = resolve_database(fetch(:target, false), false)

    # backup target
    backup = "#{shared_path}" + output_file(db_target)
    run export(backup, db_target, credentials_remote)

    # copy source
    run "mysqldump #{credentials_remote} #{db_src} | mysql #{db_target}"
  end

  def resolve_database(arg, local)
    config = mysql_local
    config = mysql_remote unless local

    if arg then
      if arg.equals?("true") then
        db = config[:alternative_db]
      else
        db = target
      end
    else
      db = config[:db]
    end

    return db
  end


  def upload_sql_to_server(file, database, creds)
    create_shared_folders()
    
    remote_file = "#{shared_path}/mysql/uploads/#{database}.sql.gz"
    backup_file = "#{shared_path}/mysql/backups/#{database}_#{current_time}.sql.gz"

    system "rsync -rv #{file} #{user}@#{ip}:#{remote_file}"

    run "mysql #{creds} -e 'CREATE DATABASE IF NOT EXISTS #{database};'"

    # export existing as a backup
    run export(backup_file, database, creds)

    # import new database
    run import(remote_file, database, creds)
    run "rm -rf "+ remote_file
  end

  def credentials(env, username, password = nil, host = nil, socket = nil, configfile = nil)
    # if we want to ask the user for the remote password name then do so, 
    # otherwise we use the auto login functionality of mysql (my.cnf file)
    # at the user level
    if password === nil && configfile === nil then
      password = Capistrano::CLI.password_prompt("Enter #{env} mysql password: ")
    end

    (username ? " -u #{username} " : '') +
    (password ? " -p'#{password}' " : '') +
    (host ? " -h #{host}" : '') +
    (socket ? " -S#{socket}" : '')
  end

  def credentials_local
    credentials("local",
      mysql_local[:user],
      mysql_local[:password],
      mysql_local[:host],
      mysql_local[:socket],
      mysql_local[:config_file]
    )
  end

  def credentials_remote
    credentials("remote", 
      mysql_remote[:user],
      mysql_remote[:password],
      mysql_remote[:host],
      mysql_remote[:socket],
      mysql_remote[:config_file]
    )
  end

  def export(file, database, credentials)
    "mysqldump #{credentials} #{database} \
      --add-drop-table \
      --lock-tables \
      --extended-insert \
      --quick | gzip > #{file}"
  end

  def import(file, database, credentials)
    if file.end_with?(".gz") then
      return "gunzip < #{file} | mysql #{credentials} -D #{database}"
    else
      return "mysql #{credentials} -D #{database} < #{file}"
    end
  end
  
  def output_file(database)
    @output_file ||= "#{database}_#{current_time}.sql.gz"
  end

  def create_shared_folders
    run "#{try_sudo} mkdir -p #{shared_path}/mysql"
    run "#{try_sudo} mkdir -p #{shared_path}/mysql/{uploads,backups}"

    run "#{try_sudo} chown -R #{user}:#{group} #{shared_path}/mysql"
    run "#{try_sudo} chmod -R 775 #{shared_path}/mysql"
  end
end