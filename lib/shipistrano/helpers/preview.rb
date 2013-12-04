#
# DNA Shipistrano
#
# = Preview.dna.co.nz
#
# Contains helpers for managing a deploy that has a 'preview' folder on preview.dna.co.nz
#
# == Variables
#
# == Tasks
#
# == Todo
#
# - Tests
# - Document behaviour with shared assets, backup live assets vs staging
#
set :app, "preview.dna.co.nz"
set :application, :app
set :ip, "120.138.30.185"
set :deploy_to, "/srv/preview.dna.co.nz/site_files/#{deploy_code}/"
set :site_symlink, "/srv/preview.dna.co.nz/site_symlinks/#{deploy_code}"
set :auth_user, "#{deploy_code}"
set :auth_pass, "#{deploy_pass}"

namespace :preview_setup do

  desc <<-DESC
    Fix the permissions on the assets folder

  DESC
  task :setup_dir do
    run "#{try_sudo} mkdir -p #{deploy_to}"
    run "#{try_sudo} mkdir -p #{deploy_to}shared"
    run "#{try_sudo} mkdir -p #{deploy_to}releases"
    run "#{try_sudo} chown #{user}:#{group} #{deploy_to}"
    run "#{try_sudo} chown #{user}:#{group} #{deploy_to}shared"
    run "#{try_sudo} chown #{user}:#{group} #{deploy_to}releases"
  end

  desc <<-DESC
    Add symlink to symlinks folder outside the site_files folder

  DESC
  task :additional_symlink do
    run "rm -f #{site_symlink}"
    run "ln -s #{release_path} #{site_symlink}"
  end

  after('deploy:create_symlink', 'preview_setup:additional_symlink')

end