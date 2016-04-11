#
# DNA Shipistrano
#
# = Node
#
# Contains helpers for managing a basic node app.
#
# == Variables
#
#
# == Tasks
#

namespace :node do
    desc <<-DESC
        Run npm install
    DESC
    task :npm_install do
        run "cd #{latest_release} && npm install"
    end
end

after('deploy:finalize_update', 'node:npm_install')
