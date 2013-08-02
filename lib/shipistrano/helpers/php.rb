#
# DNA Shipistrano
#
# = PHP
#
# Provides helper functions for dealing with PHP on servers.
#
# == Variable Exports
#
# - *php_bin* 
#
# == Task Exports
#
# - *php:info*
#
# == Todo
#
# (nil)
#
namespace :php do
  set :php_bin, "php"

  #
  # Short cut to check the PHP version on the remote machine.
  #
  desc "Runs a PHP info on the remote server"
  task :info do
    run "php -i"
  end
end