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
end