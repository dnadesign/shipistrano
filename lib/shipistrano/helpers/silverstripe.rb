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
# - *silverstripe:check_database* check if the database has been setup
# - *silverstripe:flush_cache* flush the cache via sake
# - *silverstripe:install_sake* installs sake on the server
#

# SilverStripe stores assets in assets by default
set :assets_folder, fetch(:assets_folder, "assets")
set :assets_path, fetch(:assets_path, "")

namespace :silverstripe do

  def database_exists?
    exists = false

    run "mysql --execute=\"show databases;\"" do |channel, stream, data|
      exists = exists || data.include?(mysql_database)
    end

    exists
  end

  def drop_database_and_user()
    run "mysql --execute=\"DROP DATABASE #{mysql_database};\""
    run "mysql --execute=\"DROP USER #{mysql_user}@localhost;\""
  end

  def create_database()
    run "mysql --execute=\"CREATE DATABASE #{mysql_database};\""
  end

  def create_user()
    run "mysql --execute=\"CREATE USER #{mysql_user}@localhost IDENTIFIED BY \'#{mysql_password}\';\""
  end

  def setup_database_permissions()
    grant_sql = "GRANT ALL PRIVILEGES ON #{mysql_database}.* TO #{mysql_user}@localhost;";
    run "mysql --execute=\"#{grant_sql}\""
  end

  # def setup_ss_environment
  def setup_ss_environment()
    create_env = <<-PHP
<?php
define('SS_ENVIRONMENT_TYPE', 'live');

define('SS_DATABASE_SERVER', 'localhost');
define('SS_DATABASE_USERNAME', '#{mysql_user}');
define('SS_DATABASE_PASSWORD', '#{mysql_password}');

define('SS_DEFAULT_ADMIN_USERNAME', 'dna');
define('SS_DEFAULT_ADMIN_PASSWORD', '#{ss_admin_pw}');

global $_FILE_TO_URL_MAPPING;
$_FILE_TO_URL_MAPPING['#{deploy_to}current/'] = 'http://staging.#{app}';
$_FILE_TO_URL_MAPPING['#{deploy_to}production/'] = 'http://#{app}';
    PHP

    run "if [ -f #{deploy_to}_ss_environment.php ]; then rm #{deploy_to}_ss_environment.php; fi"
    put create_env, "#{deploy_to}_ss_environment.php"
  end

  desc <<-DESC
    Setup database, db user and _ss_environment

  DESC
  task :setup_database, :on_error => :continue do
    unless database_exists?
      set(:mysql_password) { Capistrano::CLI.ui.ask("Mysql password: ") }
      create_database()
      create_user()
      setup_database_permissions()
      setup_ss_environment()
    end
  end

  desc <<-DESC
    Rempove database and db user

  DESC
  task :remove_database, :on_error => :continue do
    if database_exists?
      drop_database_and_user()
    end
  end

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

  desc <<-DESC
    Fix cache folder

  DESC
  task :fix_perms_cache_folder do
    run "#{try_sudo} chmod -R 777 #{production_folder}/silverstripe-cache"
  end

  after('publish:code', 'silverstripe:fix_perms_cache_folder')

end
