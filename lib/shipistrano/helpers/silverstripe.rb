#
# DNA Shipistrano
#
# SilverStripe - contains helpers for managing a generic deploy of 
# SilverStripe.
#
# Copyright (c) 2013, DNA Designed Communications Limited
# All rights reserved.

set :assets_folder, "assets"
set :assets_path, ""

namespace :silverstripe do

  desc "Clear the cache by viewing the homepage"
  task :rebuild_hometemplate, :on_error => :continue do
    if remote_command_exists?("sake") then
      run "cd #{latest_release}; sake flush=all"
    end
  end

  after('deploy:finalize_update', 'silverstripe:rebuild_hometemplate')

  desc "Installs sake on the machine and symlinks it to the usr/local/bin"
  task :install_sake do
    run "#{try_sudo} #{latest_release}/framework/sake installsake"
  end

  desc "Check server requirements for the SilverStripe installation"
  task :check_requirements do
    core.fix_permissions
    
    system "rsync -rv cap/assets/silverstripe_reqcheck.php #{user}@#{ip}:#{deploy_to}/shared/reqcheck.php"
    
    run "php #{shared_path}/reqcheck.php"
  end

  desc "Create cache folder"
  task :create_cache_folder do
    run "#{try_sudo} mkdir #{latest_release}/silverstripe-cache"
    run "#{try_sudo} chmod -R 777 #{latest_release}/silverstripe-cache"
  end

  after('deploy:symlink', 'silverstripe:create_cache_folder')
end
