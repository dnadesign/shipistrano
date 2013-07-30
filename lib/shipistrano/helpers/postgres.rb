#
# DNA Shipistrano
#
# Postgres - contains helpers for managing a deploy that has a Postgres database 
# that needs to be accessed.
#
# Assumes your local environment has a user called root and a password of 
# password
# Copyright (c) 2013, DNA Designed Communications Limited
# All rights reserved.

namespace :postgres do
  
  desc "Open up a remote postgres console"
  task :console do
    auth = capture "cat #{shared_path}/config/database.yml"
    puts "PASSWORD::: #{auth.match(/password: (.*$)/).captures.first}"
    hostname = find_servers_for_task(current_task).first
    exec "ssh #{hostname} -t 'source ~/.zshrc && psql -U #{application} #{postgresql_database}'"
  end

  desc "Uploads the local database to the remote machine"
  task :upload do
    system "mysqldump #{mysql_database} \
      --add-drop-table \
      --lock-tables \
      --extended-insert \
      --quick \
      -u root -ppassword > /tmp/export-local-#{mysql_database}.sql"

    system "rsync -rv /tmp/export-local-#{mysql_database}.sql #{user}@#{ip}:#{deploy_to}/shared/"
    
    # if we want to ask the user for the remote password name then do so, 
    # otherwise we use the auto login functionality of mysql (my.cnf file)
    # at the user level
    if fetch(:mysql_ask_for_password, true) == true then
      _cset(:mysql_remote_password) { Capistrano::CLI.password_prompt("Enter server MySQL password: ") }  
      
      run "mysql -u #{mysql_user} -p#{mysql_remote_password} --execute 'CREATE DATABASE IF NOT EXISTS #{mysql_database};'" 
      run "mysql -u #{mysql_user} -p#{mysql_remote_password} -D #{mysql_database} < #{shared_path}/export-local-#{mysql_database}.sql"
    else
      run "mysql -u #{mysql_user} --execute 'CREATE DATABASE IF NOT EXISTS #{mysql_database};'"
      run "mysql -u #{mysql_user} -D #{mysql_database} < #{shared_path}/export-local-#{mysql_database}.sql"
    end
    
    run "rm -rf #{shared_path}/export-local-#{mysql_database}.sql"
  end
  
  desc "Copys the staging database {database_name} to {database_name}_prod if \
  required. Such as when a site has the production module installed"
  task :publish do
    run "rm -rf #{shared_path}/exported_stage_database.sql"
    run "mysqldump --defaults-file=/home/#{user}/.my.cnf \
      #{mysql_database} \
      --add-drop-table \
      --lock-tables \
      --extended-insert --quick  > #{shared_path}/exported_stage_database.sql"
      
    run "rm -rf #{shared_path}/exported_prod_database.sql"
    run "mysql -u #{mysql_user} --execute 'CREATE DATABASE IF NOT EXISTS #{mysql_database}_prod'"
    run "mysqldump --defaults-file=/home/#{user}/.my.cnf \
      #{mysql_database}_prod \
      --add-drop-table \
      --lock-tables \
      --extended-insert --quick  > #{shared_path}/exported_prod_database.sql"
               
    run "mysql -u #{mysql_user} -D #{mysql_database}_prod < #{shared_path}/exported_stage_database.sql"
  end
end

before('postgres:upload', 'core:fix_permissions')
before('postgres:publish', 'core:fix_permissions')