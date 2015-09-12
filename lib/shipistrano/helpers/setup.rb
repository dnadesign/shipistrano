#
# DNA Shipistrano
#
# = Setup

namespace :setup do

  desc <<-DESC
    Setup all the folders that are needed

  DESC
  task :dirs do
    run "#{try_sudo} mkdir -p #{deploy_to}"
    run "#{try_sudo} mkdir -p #{deploy_to}shared"
    run "#{try_sudo} mkdir -p #{deploy_to}releases"
    run "#{try_sudo} mkdir -p #{deploy_to}shared/mysql_uploads"
    run "#{try_sudo} mkdir -p #{deploy_to}shared/solr"
    run "#{try_sudo} mkdir -p #{deploy_to}shared/mysql_backups"
    run "#{try_sudo} chown #{user}:#{group} #{deploy_to}"
    run "#{try_sudo} chown #{user}:#{group} #{deploy_to}shared"
    run "#{try_sudo} chown #{user}:#{group} #{deploy_to}releases"
    run "#{try_sudo} chown #{user}:#{group} #{deploy_to}shared/mysql_uploads"
    run "#{try_sudo} chown #{user}:#{group} #{deploy_to}shared/solr"
    run "#{try_sudo} chown #{user}:#{group} #{deploy_to}shared/mysql_backups"
  end
end
