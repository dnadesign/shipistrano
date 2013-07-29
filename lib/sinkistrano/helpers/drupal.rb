#
# DNA Sinkistrano
#
# Drupal - contains helpers for managing a generic deploy of drupal / pressflow
#
# Copyright (c) 2013, DNA Designed Communications Limited
# All rights reserved.

# To clear the cache include the following file as a clear.php in the route of
# this project directory since drush does not do this for us:
#
# <?php
# include_once './includes/bootstrap.inc';
# drupal_bootstrap(DRUPAL_BOOTSTRAP_FULL);
# drupal_flush_all_caches();
set :clear_file, "clear.php"
set :assets_folder, "files"
set :assets_path, "sites/default/"
set :drush, "drush"

namespace :drupal do

  desc "Flush the Drupal cache system."
  task :clear, :only => { :primary => true } do
    run "#{sudo} #{drush} cc all --uri=http://#{app}"
    run "#{sudo} #{drush} cc all --uri=http://staging.#{app}"

    run "if [ -f #{deploy_to}/production/#{clear_file} ]; then curl http://#{app}/#{clear_file}; fi"
    run "if [ -f #{deploy_to}/current/#{clear_file} ]; then curl http://staging.#{app}/#{clear_file}; fi"
  end

end

after('deploy:finalize_update', 'drupal:clear')
after('publish:code', 'drupal:clear')