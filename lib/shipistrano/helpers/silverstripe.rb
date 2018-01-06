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
set :sake_path, fetch(:sake_path, 'vendor/bin/sake') # Allows overriding
set :ss_preview, fetch(:ss_preview, false)

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

    if ss_preview
      create_env = <<-PHP
SS_DATABASE_CLASS="MySQLPDODatabase"
SS_DATABASE_SERVER="localhost"
SS_DATABASE_USERNAME="#{mysql_user}"
SS_DATABASE_PASSWORD="#{mysql_password}"
SS_DEFAULT_ADMIN_USERNAME="dna"
SS_DEFAULT_ADMIN_PASSWORD="#{ss_admin_pw}"
SS_ENVIRONMENT_TYPE="live"
SS_ENVIRONMENT_TYPE="#{mysql_database}"

SS_DATABASE_PREFIX="deploy_"
SOLR_INDEXSTORE_PATH="./shared/solr/"
SOLR_PORT="8984"

  PHP
    else
        create_env = <<-PHP
SS_DATABASE_CLASS="MySQLPDODatabase"
SS_DATABASE_SERVER="localhost"
SS_DATABASE_USERNAME="#{mysql_user}"
SS_DATABASE_PASSWORD="#{mysql_password}"
SS_DEFAULT_ADMIN_USERNAME="dna"
SS_DEFAULT_ADMIN_PASSWORD="#{ss_admin_pw}"
SS_ENVIRONMENT_TYPE="live"
SS_ENVIRONMENT_TYPE="#{mysql_database}"
  PHP
    end

    run "if [ -f #{deploy_to}/releases/.env ]; then rm #{deploy_to}/releases/.env; fi"

    File.write("#{local_cache}/releases/.env", create_env)
    system "rsync -rv #{local_cache}/releases/.env #{user}@#{ip}:#{deploy_to}/releases/.env"
  end


  task :setup_environment do
    setup_database_permissions()
    setup_ss_environment()
  end


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
    Installs sake on the remote machine. Assumes you have done at least one
    release.
  DESC
  task :install_sake do
    run "#{try_sudo} #{latest_release}/#{sake_path} installsake"
  end


  desc <<-DESC
    Create cache folder
  DESC
  task :create_cache_folder do
    if fetch(:use_silverstripe_cache, false) != false then
      run "#{try_sudo} mkdir #{latest_release}/silverstripe-cache"
    end
  end
  before('silverstripe:build_database', 'silverstripe:create_cache_folder')


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
  task :fix_owner_cache_folder_preview, :on_error => :continue do
    if fetch(:use_silverstripe_cache, false) != false then
      run "chmod -R 777 #{latest_release}/silverstripe-cache/#{php_group}"
    end
  end

  desc <<-DESC
    Check server requirements for the SilverStripe installation
  DESC
  task :check_requirements do
    ship.fix_permissions
    system "rsync -rv cap/assets/silverstripe_reqcheck.php #{user}@#{ip}:#{deploy_to}/shared/reqcheck.php"
    run "php #{shared_path}/reqcheck.php"
  end
end