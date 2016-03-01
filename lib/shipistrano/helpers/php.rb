#
# DNA Shipistrano
#
# = PHP
#
# Provides helper functions for dealing with PHP on servers.
#
# == Variables
#
# - *php_bin* 
#
# == Tasks
#
# - *php:info*
#
# == Todo
#
# (nil)
#
namespace :php do
  set :php_bin, fetch(:php_bin, "php")

  desc <<-DESC
  	Runs a PHP info on the remote server.

  DESC
  task :info do
    run "php -i"
  end


  desc "Clear PHP caches. Cannot use apachectl as deploy will not be sudo."
  task :clear_cache do
  	run 'php -r "echo (function_exists(\'xcache_clear_cache\')) ? xcache_clear_cache() : 1;"'
  	run 'php -r "echo (function_exists(\'apc_clear_cache\')) ? apc_clear_cache() : 1;"'
  end
end