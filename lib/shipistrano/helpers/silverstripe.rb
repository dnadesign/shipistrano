#
# DNA Shipistrano
#
# = SilverStripe
#
# Contains helpers for managing a generic deploy of SilverStripe.
#
# == Variables
#
# (nil)
#
# == Tasks
#
# - *silverstripe:flush_cache* flush the cache via sake
# - *silverstripe:install_sake* installs sake on the server
#

# SilverStripe stores assets in assets by default
set :assets_folder, fetch(:assets_folder, "assets")
set :assets_path, fetch(:assets_path, "")

namespace :silverstripe do

  desc <<-DESC
    Clear the cache for both cli user and web user.

  DESC
  task :flush_cache, :on_error => :continue do
    if remote_command_exists?("sake") then
      run "cd #{latest_release}; sake flush=all"
    end
  end

  after('deploy:finalize_update', 'silverstripe:flush_cache')

  desc <<-DESC
    Build the database (dev/build).

  DESC
  task :build_database, :on_error => :continue do
    if remote_command_exists?("sake") then
      run "cd #{latest_release}; sake dev/build flush=all"
    end
  end

  desc <<-DESC
    Installs sake on the remote machine. Assumes you have done at least one
    release. 
    
  DESC
  task :install_sake do
    run "#{try_sudo} #{latest_release}/framework/sake installsake"
  end

  desc <<-DESC
    Check server requirements for the SilverStripe installation

  DESC
  task :check_requirements do
    ship.fix_permissions
    
    system "rsync -rv cap/assets/silverstripe_reqcheck.php #{user}@#{ip}:#{deploy_to}/shared/reqcheck.php"
    
    run "php #{shared_path}/reqcheck.php"
  end

  desc <<-DESC
    Create cache folder

  DESC
  task :create_cache_folder do
    run "#{try_sudo} mkdir #{latest_release}/silverstripe-cache"
    run "#{try_sudo} chmod -R 777 #{latest_release}/silverstripe-cache"
  end

  after('deploy', 'silverstripe:create_cache_folder')
end
