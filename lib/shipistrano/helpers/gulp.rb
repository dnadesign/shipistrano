#
# DNA Shipistrano
#
# = Gulp
#
# Contains helpers for running gulp build
#
# == Variables
#
#
# == Tasks
#

namespace :gulp do
    desc <<-DESC
        Run gulp
    DESC

    task :gulp_build do
        run "cd #{latest_release} && node_modules/gulp/bin/gulp.js build"
    end
end

after('node:npm_install', 'gulp:gulp_build')
