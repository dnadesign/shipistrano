#
# DNA Shipistrano
#
# =	Drupal 
# 
# Contains helpers for managing a generic deploy of drupal / pressflow.
#
# To clear the cache include the following file as a clear.php in the route of
# this project directory since drush does not do this for us:
#
# <?php
# include_once './includes/bootstrap.inc';
# drupal_bootstrap(DRUPAL_BOOTSTRAP_FULL);
# drupal_flush_all_caches();
#
# == Variables
#
# (nil)
#
# == Tasks
#
# - *drupal:clear_cache* 
#
# == Todo
#
# - Everything. Most of this can be filled out from NZP source
#
set :clear_file, fetch(:clear_file, "clear.php")
set :assets_folder, fetch(:asset_folder, "files")
set :assets_path, fetch(:assets_path, "sites/default/")
set :drush, fetch(:drush, "drush")

namespace :drupal do

  desc <<-DESC
  	Flush the Drupal cache system.
  DESC
  task :clear_cache, :only => { :primary => true } do   
    run "#{sudo} #{drush} cc all --uri=http://#{app}"
  end

end

after('deploy:finalize_update', 'drupal:clear')