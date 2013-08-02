# 
# DNA Shipistrano
#
# Core - contains general default configuration varibles and tasks for managing 
# capistrano.
#
# Copyright (c) 2013, DNA Designed Communications Limited
# All rights reserved.

require  File.expand_path(File.join(File.dirname(__FILE__), "shipistrano", "helpers", "helpers.rb"));
require  File.expand_path(File.join(File.dirname(__FILE__), "shipistrano", "strategies", "rsync_with_remote_cache_composed.rb"));

# --------------------------------------
# :section: Core configuration
#
# You know when I said Shipistrano is opinionated? Well here are some of it's
# opinions. You can configure any of these from your capfile at the root.
#
# --------------------------------------

set :keep_releases,     5
set :copy_exclude,      [".git", ".DS_Store", ".svn", "Makefile", "capistrano", "cap", "capfile", "config.rb", :assets_folder]
set :time,              Time.new.to_i
set :scm_username,      "git"
set :scm,               "git"
set :source,            ComposedGitCache.new(self)
set :strategy,          RsyncWithRemoteCacheComposed.new(self)
set :deploy_via,        :rsync_with_remote_cache
set :local_cache,       "/tmp/#{app}"
set :rsync_options,     '-az --delete --exclude=.git --exclude=' + copy_exclude.join(' --exclude=')
set :php_bin,           "php"
set :group_writable,    false
set :git_enable_submodules, true

namespace :core do
  #
  # Fixes the permissions on the remote server folder. Uses sudo if
  # available for the user set via :user
  #
  desc "Fix the permissions on the remote folder."
  task :fix_permissions do
    if fetch(:ignore_ownership, false) != false then
      if fetch(:group, false) != false then
        owner = "#{user}"
      else
        owner = "#{user}:#{group}"
      end

      run "if [ -d #{deploy_to} ]; then #{try_sudo} chown -R #{owner} #{deploy_to}; fi"
    end
  end
  #
  # Removes the robots.txt file. See add_disallow_robots
  #
  desc "Remove the robots.txt file created by add_disallow_robots"
  task :remove_robots do
   run "#{try_sudo} rm -rf #{latest_release}/robots.txt"
  end

end

before('deploy', 'core:fix_permissions')
