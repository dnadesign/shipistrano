#
# DNA Shipistrano
#
# PHP - Provides helper functions for dealing with PHP on servers.
#
# Copyright (c) 2013, DNA Designed Communications Limited
# All rights reserved.

namespace :php do
	
  #
  # Short cut to check the PHP version on the remote machine.
  #
  desc "Runs a PHP info on the remote server"
  task :php_info do
    run "php -i"
  end