# 
# DNA Shipistrano
#
# = Ship
#
# Contains general default configuration variables and tasks for managing 
# capistrano.
#
# == Variable Exports
#
# (nil)
#
# == Task Exports
#
# *fix_permissions* fix permissions on the deploy to folder.
#
# == Todo
# 
# (nil)
#

require  File.expand_path(File.join(File.dirname(__FILE__), "shipistrano", "helpers", "helpers.rb"));
require  File.expand_path(File.join(File.dirname(__FILE__), "shipistrano", "strategies", "rsync_with_remote_cache_composed.rb"));

# --------------------------------------
# :section: Shipistrano core configuration
#
# You know when I said Shipistrano is opinionated? Well here are some of it's
# opinions. You can configure any of these from your capfile at the root.
#
# --------------------------------------
set :keep_releases,     fetch(:keep_releases, 5)
set :copy_exclude,      fetch(:copy_exclude, [".git", ".DS_Store", ".svn", "Makefile", "capistrano", "cap", "capfile", "config.rb", :assets_folder])

set :scm_username,      fetch(:scm_username, "git")
set :scm,               fetch(:scm, "git")
set :local_cache,       fetch(:local_cache, "/tmp/shipistrano/#{app}")
set :rsync_options,     fetch(:rsync_options, '-az --delete --exclude=.git --exclude=' + copy_exclude.join(' --exclude='))
set :group_writable,    fetch(:group_writable, false)

# Defaults that should always be set
set :git_enable_submodules, true
set :time,              Time.new.to_i

# Internal deploy strategies. Plan to make this dynamic in the future, need to
# add our FTP strategy
set :source,            ComposedGitCache.new(self)
set :strategy,          RsyncWithRemoteCacheComposed.new(self)
set :deploy_via,        :rsync_with_remote_cache
set :default_shell,     fetch(:default_shell, '/bin/bash -l')

namespace :ship do
  
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
end

before('deploy', 'ship:fix_permissions')