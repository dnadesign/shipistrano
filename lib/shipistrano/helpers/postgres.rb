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

namespace :pgsql do
  
  desc "Open up a remote postgres console"
  task :console do
    hostname = find_servers_for_task(current_task).first
    exec "ssh #{user}@#{ip} -t 'psql -U #{pgsql_user} #{pgsql_database}'"
  end

  desc "Uploads the local database to the remote machine"
  task :upload do
    system "pg_dump #{pgsql_database} > /tmp/export-local-#{pgsql_database}.sql"
    system "rsync -rv /tmp/export-local-#{pgsql_database}.sql #{user}@#{ip}:#{deploy_to}/shared/"
    
    # if we want to ask the user for the remote password name then do so, 
    # otherwise we use the auto login functionality of mysql (my.cnf file)
    # at the user level
    if fetch(:pgsql_ask_for_password, true) == true then
      _cset(:pgsql_remote_password) { Capistrano::CLI.password_prompt("Enter server Postgres password: ") }  
      run "psql -U #{pgsql_user} -W #{pgsql_remote_password} -d #{pgsql_database} -f #{shared_path}/export-local-#{pgsql_database}.sql"
    else
      run "psql -U #{mysql_user} -d #{pgsql_database} -f #{shared_path}/export-local-#{pgsql_database}.sql"
    end
    
    run "rm -rf #{shared_path}/export-local-#{pgsql_database}.sql"
  end
  
  desc "Copys the staging database {database_name} to {database_name}_prod if \
  required. Such as when a site has the production module installed"
  task :publish do
    run "rm -rf #{shared_path}/exported_stage_database.sql"
    run "pg_dump -d #{pgsql_database} -f #{shared_path}/exported_stage_database.sql"
      
    run "rm -rf #{shared_path}/exported_prod_database.sql"
    run "pg_dump -d #{pgsql_database}_prod -f #{shared_path}/exported_prod_database.sql"
               
    run "psql -d #{pgsql_database}_prod -f #{shared_path}/exported_stage_database.sql"
  end
end

before('pgsql:upload', 'core:fix_permissions')
before('pgsql:publish', 'core:fix_permissions')