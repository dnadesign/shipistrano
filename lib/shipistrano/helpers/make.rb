#
# DNA Shipistrano
#
# = Make
#
# Contains helpers for running Make commands.
#
# == Variables
#
#
# == Tasks
#

namespace :make do
    desc <<-DESC
        Run script build
    DESC
    task :build_scripts do
        run "cd #{latest_release} && make build"
    end
end

after('deploy:finalize_update', 'make:build_scripts')
