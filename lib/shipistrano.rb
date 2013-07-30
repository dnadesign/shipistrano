# 
# DNA Shipistrano
#
# Core - contains general default configuration and tools for managing 
# capistrano.
#
# Copyright (c) 2013, DNA Designed Communications Limited
# All rights reserved.

require File.join(File.dirname(__FILE__), 'helpers/helpers.rb');
require File.join(File.dirname(__FILE__), 'strategy/rsync_with_remote_cache_composed.rb');

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
	desc "Fix the permissions on the remote folder."
	task :fix_permissions do
		if fetch(:ignore_ownership, false) != true then
			run "if [ -d #{deploy_to} ]; then #{try_sudo} chown -R #{user}:#{group} #{deploy_to}; fi"
		end

		if fetch(:assets_folder, false) then
			run "#{try_sudo} mkdir -p #{shared_path}/#{assets_folder}"
			run "#{try_sudo} chmod -R 775 #{shared_path}/#{assets_folder}"
		end
	end

	desc "Symlinks the assets from the shared folder to the latest release"
	task :symlink_assets do
		if fetch(:assets_folder, false) then
			run "ln -nfs #{shared_path}/#{assets_folder}/ #{latest_release}/#{assets_path}#{assets_folder}"
		end

		core.fix_permissions
	end

	desc "Uploads the assets from the dev copy to the remote server."
	task :upload_assets do
		if fetch(:assets_folder, false) then
			system "rsync -rv #{assets_path}#{assets_folder}/ #{user}@#{ip}:#{deploy_to}/shared/#{assets_folder}"
		end

		core.fix_permissions
	end

	desc "Add a robots.txt to the default release"
	task :add_robots_file do
		run "echo -e 'User-agent: * \nDisallow: /' > #{latest_release}/robots.txt"
	end

	desc "Remove the robots.txt file"
	task :remove_robots do
		run "#{try_sudo} rm -rf #{latest_release}/robots.txt"
	end

	desc "Runs a PHP info on the remote server"
	task :php_info do
		run "php -i"
	end

	# desc "Upload coming soon page"
	# task :upload_coming_soon
	# end
end

before('deploy', 'core:fix_permissions')
after('deploy', 'core:symlink_assets')