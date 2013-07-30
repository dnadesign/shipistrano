#
# DNA Shipistrano
#
# Mysql - contains helpers for managing a deploy that has a MySQL database that 
# needs to be accessed.
#
# Assumes your local environment has a my.cnf configuration setup so that the
# username and password do not need to be provided within this.
#
# Copyright (c) 2013, DNA Designed Communications Limited
# All rights reserved.

namespace :mysql do
  
  desc "Open up a remote mysql console"
  task :console do
    hostname = find_servers_for_task(current_task).first
    exec "ssh #{user}@#{ip} -t 'mysql -u #{mysql_user} -D #{mysql_database}'"
  end

  desc "Uploads the local database to the remote machine"
  task :upload do
    system "mysqldump #{mysql_database} \
      --add-drop-table \
      --lock-tables \
      --extended-insert \
      --quick \
      -u root > /tmp/export-local-#{mysql_database}.sql"

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

before('mysql:upload', 'core:fix_permissions')
before('mysql:publish', 'core:fix_permissions')