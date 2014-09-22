#
# Whenever is a tool for automating the setup of cron jobs (and runner etc).
# https://github.com/javan/whenever
# 
# Note: The whenever gem must be installed on the dev machine, and the server.
# 
# Usage: Include a config/schedule.rb file in your project root.
# See the example on github for format.
#

set :whenever_identifier, "#{app}"
set :whenever_roles, [:web]
require "whenever/capistrano"