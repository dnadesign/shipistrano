#
# DNA Shipistrano
#
# Mysql - contains helpers for managing a deploy that has a MySQL database that 
# needs to be accessed.
#
# Configuration:
# (specifying a configuration file is optional, but recommended)
# 
# set :db_remote, {
#   :name => 'db_name',
#   :configfile => "~/.my.cnf",
#   :host => 'host',
#   :user => 'mysqluser'
#   :password => 'password'
# }
#
# set :db_remote, {
#   :name => 'live_db_name',
#   :configfile => "~/.mylive.cnf",
#   :host => 'livehost',
#   :user => 'livemysqluser'
#   :password => 'livepassword'
# }
# 
# Usage:
# => cap mysql:upload
# => cap mysql:publish
#
# Copyright (c) 2013, DNA Designed Communications Limited
# All rights reserved.


namespace :mysql do

  desc "Uploads the local database to the remote machine. Pass a 'localfile' parameter to override ( cap mysql:upload -s localfile=/my/file/path/file.sql.gz)"
  task :upload do
    database = db_local[:name]
    remotefile = "#{shared_path}/" + output_file(database)
    localfile = fetch(:localfile, false)
    if !localfile
      localfile = "/tmp/" + output_file(database)
      system export(db_local[:name], credentials_local, localfile)
    end
    puts "uploading #{localfile} to remote server"
    top.upload(localfile, remotefile) #from local, to remote
    run import(db_remote[:name], credentials_remote, remotefile)
    run "rm -rf "+ remotefile
  end

  desc "Downloads database from remote machine, to local host."
  task :download do
    database = db_local[:name]
    remotefile = "#{shared_path}/" + output_file(database)
    localfile = "/tmp/" + output_file(database)
    run export(db_remote[:name], credentials_remote, remotefile)
    top.download(remotefile,localfile)
    run "rm -rf "+ remotefile
    system import(db_local[:name], credentials_local, localfile)
  end

  desc "Copys the staging database {database_name} to {database_name}_prod if \
  required. Such as when a site has the production module installed"
  task :publish do
    database = db_remote[:name]
    stagedbfile = "#{shared_path}/exported_stage_database.sql"
    run "rm -rf " + stagedbfile
    run export(database, credentials_remote, stagedbfile)
    productiondbfile = "#{shared_path}/exported_prod_database.sql"
    run "rm -rf" + productiondbfile
    run export("#{database}_prod", credentials_remote, productiondbfile) #back up existing
    run import("#{database}_prod", credentials_remote, stagedbfile)
  end

  #generate credentials string
  def credentials(localremote, username, password = nil, host = nil, socket = nil, configfile = nil)
    # if we want to ask the user for the remote password name then do so, 
    # otherwise we use the auto login functionality of mysql (my.cnf file)
    # at the user level
    if password === nil && configfile === nil then
      password = Capistrano::CLI.password_prompt("Enter #{localremote} mysql password: ")
    end
    (configfile ? " --defaults-file="+configfile+" " : '') +
    (username ? " -u #{username} " : '') +
    (password ? " -p'#{password}' " : '') +
    (host ? " -h #{host}" : '') +
    (socket ? " -S#{socket}" : '')
  end

  def credentials_local
    credentials("local",db_local[:user],db_local[:password],db_local[:host],db_local[:socket],db_local[:configfile])
  end

  def credentials_remote
    credentials("remote",db_remote[:user],db_remote[:password],db_remote[:host],db_remote[:socket],db_remote[:configfile])
  end

  # export database from mysql
  def export(database, credentials, file)
    "mysqldump #{credentials} #{database} \
      --add-drop-table \
      --lock-tables \
      --extended-insert \
      --quick | gzip > #{file}"
  end

  # import database to mysql
  def import(database, credentials, file)
    "mysql #{credentials} --execute 'CREATE DATABASE IF NOT EXISTS #{database};'" +
    " && gunzip < #{file} | mysql #{credentials} -D #{database}"
  end
  
  def output_file(database)
    @output_file ||= "#{database}_#{current_time}.sql.gz"
  end
end