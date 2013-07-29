#
# DNA Sinkistrano
#
# Rsync with Remote Cache Composed is our custom deployment strategy to handle
# mostly PHP projects. We want to run all the heavy lifting on our locally 
# cached version of the project and then push it up to the server.
#
# Copyright (c) 2013, DNA Designed Communications Limited
# All rights reserved.

load 'deploy' if respond_to?(:namespace) # cap2 differentiator

require 'capistrano/recipes/deploy/strategy/rsync_with_remote_cache'
require 'capistrano/recipes/deploy/scm/git'

Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }


class RsyncWithRemoteCacheComposed < Capistrano::Deploy::Strategy::RsyncWithRemoteCache
  def update_local_cache
    system(command)

    mark_local_cache

    if local_file_exists?("#{local_cache}/composer.json") then
      system("cd #{local_cache} && composer install");
    end
  end
end

class ComposedGitCache < Capistrano::Deploy::SCM::Git

  default_command "git"

  def sync(revision, destination)
    git = command
    remote = origin

    execute = []
    execute << "cd #{destination}"

    if remote != 'origin'
      execute << "#{git} config remote.#{remote}.url #{variable(:repository)}"
      execute << "#{git} config remote.#{remote}.fetch +refs/heads/*:refs/remotes/#{remote}/*"
    end

    # since we're in a local branch already, just reset to specified revision rather than merge
    execute << "#{git} fetch #{verbose} #{remote} && #{git} fetch --tags #{verbose} #{remote} && #{git} reset #{verbose} --hard #{revision}"

    if variable(:git_enable_submodules)
      execute << "#{git} submodule #{verbose} init"
      execute << "#{git} submodule #{verbose} sync"

      if false == variable(:git_submodules_recursive)
        execute << "#{git} submodule #{verbose} update --init"
      else
        execute << %Q(export GIT_RECURSIVE=$([ ! "`#{git} --version`" \\< "git version 1.6.5" ] && echo --recursive))
        execute << "#{git} submodule #{verbose} update --init $GIT_RECURSIVE"
      end
    end

    execute.join(" && ")
  end
end

