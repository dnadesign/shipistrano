#
# DNA Shipistrano
#
# = SilverStripe
#
# Contains helpers for managing a generic deploy of SilverStripe.
#
# == Variables
#
# - *use_silverstripe_cache* flag whether to include a silverstripe-cache folder
# in the root directory of a release or not.
#
# == Tasks
#
# - *silverstripe:check_database* check if the database has been setup
# - *silverstripe:flush_cache* flush the cache via sake
# - *silverstripe:install_sake_3* installs sake from silverstripe 3 on the server
# - *silverstripe:install_sake_2* installs sake from silverstripe 2 on the server

# SilverStripe stores assets in assets by default
set :assets_folder, fetch(:assets_folder, "assets")
set :assets_subfolder, fetch(:assets_subfolder, "")
set :assets_exclude, fetch(:assets_exclude,'--exclude "_resampled"')
set :assets_path, fetch(:assets_path, "")
set :use_silverstripe_cache, fetch(:use_silverstripe_cache, true)
set :php_user, fetch(:php_user, "#{user}")
set :php_group, fetch(:php_group, "#{group}")
set :sudo_sake, fetch(:sudo_sake, false)
set :sake_path, fetch(:sake_path, 'framework/sake') # Allows overriding

namespace :silverstripe do

  def database_exists?
    exists = false

    run "mysql --execute=\"show databases;\"" do |channel, stream, data|
      exists = exists || data.include?(mysql_database)
    end

    exists
  end

  def drop_database_and_user()
    if has_production
     run "mysql --execute=\"DROP DATABASE #{mysql_database}_production;\""
    end
    run "mysql --execute=\"DROP DATABASE #{mysql_database};\""
    run "mysql --execute=\"DROP USER #{mysql_user}@localhost;\""
  end

  def create_database()
    run "mysql --execute=\"CREATE DATABASE #{mysql_database};\""
    if has_production
      run "mysql --execute=\"CREATE DATABASE #{mysql_database}_production;\""
    end
  end

  def create_user()
    run "mysql --execute=\"CREATE USER #{mysql_user}@localhost IDENTIFIED BY \'#{mysql_password}\';\""
  end

  def setup_database_permissions()
    grant_sql = "GRANT ALL PRIVILEGES ON #{mysql_database}.* TO #{mysql_user}@localhost;";
    run "mysql --execute=\"#{grant_sql}\""
    if has_production
      grant_sql = "GRANT ALL PRIVILEGES ON #{mysql_database}_production.* TO #{mysql_user}@localhost;";
      run "mysql --execute=\"#{grant_sql}\""
    end
  end

  # def setup_ss_environment
  def setup_ss_environment()

    if ss_preview
      create_env = <<-PHP
<?php
define('SS_ENVIRONMENT_TYPE', 'live');

define('SS_DATABASE_SERVER', 'localhost');
define('SS_DATABASE_USERNAME', '#{mysql_user}');
define('SS_DATABASE_PASSWORD', '#{mysql_password}');

define('SS_DEFAULT_ADMIN_USERNAME', 'dna');
define('SS_DEFAULT_ADMIN_PASSWORD', '#{ss_admin_pw}');

if($_SERVER['DOCUMENT_ROOT'] == "/srv/#{app}/production/" || (isset($_SERVER['PWD']) && $_SERVER['PWD'] == "/srv/#{app}/production")) {
  define('SS_DATABASE_SUFFIX', '_production');
}
define('SS_DATABASE_PREFIX', 'deploy_');

global $_FILE_TO_URL_MAPPING;
include('file2url.php');
if(file_exists(dirname(__FILE__) . '/file2url_production.php')) {
  include('file2url_production.php');
}

define('SOLR_INDEXSTORE_PATH', dirname(__FILE__) . '/shared/solr/');
define('SOLR_PORT', 8984);
  PHP
    else
        create_env = <<-PHP
<?php
define('SS_ENVIRONMENT_TYPE', 'live');

define('SS_DATABASE_SERVER', 'localhost');
define('SS_DATABASE_USERNAME', '#{mysql_user}');
define('SS_DATABASE_PASSWORD', '#{mysql_password}');

define('SS_DEFAULT_ADMIN_USERNAME', 'dna');
define('SS_DEFAULT_ADMIN_PASSWORD', '#{ss_admin_pw}');

if($_SERVER['DOCUMENT_ROOT'] == "/srv/#{app}/production/" || (isset($_SERVER['PWD']) && $_SERVER['PWD'] == "/srv/#{app}/production")) {
  define('SS_DATABASE_SUFFIX', '_production');
}

global $_FILE_TO_URL_MAPPING;
include('file2url.php');
if(file_exists(dirname(__FILE__) . '/file2url_production.php')) {
  include('file2url_production.php');
}
  PHP
    end


    run "if [ -f #{deploy_to}_ss_environment.php ]; then rm #{deploy_to}_ss_environment.php; fi"

    File.write("#{local_cache}_ss_environment.php", create_env)
    system "rsync -rv #{local_cache}_ss_environment.php #{user}@#{ip}:#{deploy_to}_ss_environment.php"
  end


  desc <<-DESC
    Get file to url mapping working ofr latest release
  DESC
  task :file_2_url do
    if has_production
       run "echo \"\<\?php \\$_FILE_TO_URL_MAPPING\[\'#{latest_release}\'\] = \'http://staging.#{app}/\'\;\" > #{deploy_to}file2url.php"
    else
       run "echo \"\<\?php \\$_FILE_TO_URL_MAPPING\[\'#{latest_release}\'\] = \'http://#{app}/\'\;\" > #{deploy_to}file2url.php"
    end
  end

  after('deploy:finalize_update', 'silverstripe:file_2_url')


  desc <<-DESC
    Get file to url mapping working for latest production release
  DESC
  task :file_2_url_production do
    run "echo \"\<\?php \\$_FILE_TO_URL_MAPPING\[\'#{production_folder}\'\] = \'http://#{app}/\'\;\" > #{deploy_to}file2url_production.php"
  end

  after('publish:code', 'silverstripe:file_2_url_production')


  desc <<-DESC
    Setup database, db user and _ss_environment
  DESC
  task :setup_database, :on_error => :continue do
    unless database_exists?
      set(:mysql_password) { Capistrano::CLI.ui.ask("Please enter a new MySQL password: ") }
      create_database()
      create_user()
      setup_database_permissions()
      setup_ss_environment()
    end
  end


  desc <<-DESC
    Remove database and db user
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
    if sake = detected_sake_path then
      if fetch(:sudo_sake, false) != false then
        run "cd #{latest_release} && sudo -u #{php_user} #{sake} / flush=all"
      else
        run "cd #{latest_release} && #{sake} / flush=all"
      end
    end
  end

  after('silverstripe:build_database', 'silverstripe:flush_cache')


  desc <<-DESC
    Clear the cache for both cli user and web user in production
  DESC
  task :flush_cache_production, :on_error => :continue do
    if sake = detected_sake_path then
      run "cd #{production_folder} && #{sake} / flush=all"
    end
  end

  after('silverstripe:build_database_production', 'silverstripe:flush_cache_production')


  desc <<-DESC
    Build the database (dev/build).
  DESC
  task :build_database, :on_error => :continue do
    if sake = detected_sake_path then
      if fetch(:sudo_sake, false) != false then
        run "cd #{latest_release} && sudo -u #{php_user} #{sake} dev/build flush=all"
      else
        run "cd #{latest_release} && #{sake} dev/build flush=all"
      end
    end
  end

  after('deploy:finalize_update', 'silverstripe:build_database')


  desc <<-DESC
    Build the database (dev/build) in production.
  DESC
  task :build_database_production, :on_error => :continue do
    if sake = detected_sake_path then
      if fetch(:sudo_sake, false) != false then
        run "cd #{production_folder} && sudo -u #{php_user} #{sake} dev/build flush=all"
      else
        run "cd #{production_folder} && #{sake} dev/build flush=all"
      end
    end
  end

  after('publish:code', 'silverstripe:build_database_production')


  desc <<-DESC
    Installs sake on the remote machine. Assumes you have done at least one
    release.
  DESC
  task :install_sake do
    run "#{try_sudo} #{latest_release}/framework/sake installsake"
  end


  desc <<-DESC
    Installs sake on the remote machine. Assumes you have done at least one
    release. For Silverstripe 2
  DESC
  task :install_sake_2 do
    run "#{try_sudo} #{latest_release}/sapphire/sake installsake"
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
    if fetch(:use_silverstripe_cache, false) != false then
      run "#{try_sudo} mkdir #{latest_release}/silverstripe-cache"
    end
  end

  after('silverstripe:file_2_url', 'silverstripe:create_cache_folder')

  desc <<-DESC
    Fix cache folder perms
  DESC
  task :fix_perms_cache_folder do
    if fetch(:use_silverstripe_cache, false) != false then
      run "if [ -d #{latest_release}/silverstripe-cache ]; then #{try_sudo} chmod -R 777 #{latest_release}/silverstripe-cache; fi"
    end
  end

  after('silverstripe:create_cache_folder', 'silverstripe:fix_perms_cache_folder')
  before('publish:code', 'silverstripe:fix_perms_cache_folder')

  desc <<-DESC
    Fix cache folder
  DESC
  task :fix_perms_cache_folder_production do
    if fetch(:use_silverstripe_cache, false) != false then
      run "#{try_sudo} chmod -R 777 #{production_folder}/silverstripe-cache"
    end
  end

  after('publish:code', 'silverstripe:fix_perms_cache_folder_production')

  desc <<-DESC
    Fix cache folder ownership
  DESC
  task :fix_owner_cache_folder do
    if fetch(:use_silverstripe_cache, false) != false then
      if fetch(:user, false) != fetch(:php_group, false) then
        run <<-EOF
          if [ -d #{latest_release}/silverstripe-cache/#{user} ];
            then
            #{try_sudo} rm -rf #{latest_release}/silverstripe-cache/#{group} && mv #{latest_release}/silverstripe-cache/#{user} #{latest_release}/silverstripe-cache/#{group} && echo 'ss cache built' ;
          fi
        EOF
      end
      run "#{try_sudo} chown -R #{php_user}:#{php_group} #{latest_release}/silverstripe-cache"
    end
  end

  before('deploy:create_symlink', 'silverstripe:fix_owner_cache_folder')

  desc <<-DESC
    Fix cache folder ownership preview
  DESC
  task :fix_owner_cache_folder_preview do
    if fetch(:use_silverstripe_cache, false) != false then
      run "chmod -R 777 #{latest_release}/silverstripe-cache/#{php_group}"
    end
  end

  desc <<-DESC
    Fix cache folder ownership production
  DESC
  task :fix_owner_cache_folder_production do
    if fetch(:use_silverstripe_cache, false) != false then
      run <<-EOF
        if [ -d #{production_folder}/silverstripe-cache/#{user} ];
          then
          #{try_sudo} rm -rf #{production_folder}/silverstripe-cache/#{group} && mv #{production_folder}/silverstripe-cache/#{user} #{production_folder}/silverstripe-cache/#{group} && echo 'ss cache built' ;
        fi
      EOF
      run "#{try_sudo} chown -R #{group}:#{group} #{production_folder}/silverstripe-cache"
   end
  end

  before('silverstripe:fix_perms_cache_folder_production', 'silverstripe:fix_owner_cache_folder_production')
end
