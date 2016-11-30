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
set :use_sudo, false
set :user, "deploy"

# if defined? mysql_database? then
  set :mysql_database,    "deploy_#{mysql_database}"
# end

set :app, "preview.dna.co.nz/#{deploy_code}"
set :application, "#{app}"
set :ip, "120.138.27.22"
set :deploy_to, "/srv/preview.dna.co.nz/site_files/#{deploy_code}/"
set :auth_folder, "#{deploy_to}current"
set :site_symlink, "/srv/preview.dna.co.nz/site_symlinks/#{deploy_code}"
set :auth_user, "#{deploy_code}"
set :auth_pass, "#{deploy_pass}"
set :keep_releases, 2
set :ss_preview, true
before('deploy:cleanup', 'htaccess:auth:protect')
after('deploy:update', 'deploy:cleanup')
after('silverstripe:fix_owner_cache_folder', 'silverstripe:fix_owner_cache_folder_preview')


namespace :preview_setup do

  desc <<-DESC
    Add symlink to symlinks folder outside the site_files folder

  DESC
  task :additional_symlink do
    run "rm -f #{site_symlink}"
    run "ln -s #{release_path} #{site_symlink}"
  end

  after('deploy:create_symlink', 'preview_setup:additional_symlink')

end
