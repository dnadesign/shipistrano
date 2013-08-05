# 
# DNA Shipistrano
#
# = Robots
#
# Misc tasks around dealing with Robot files. Mostly we just add them to disable
# indexing sites before we've launched them fully
#
# == Variable
#
# (nil)
#
# == Task
#
# - *robots:add_disallow_robots* add a robots.txt to block search agents for the 
# latest release.
# - *robots:remove_robots* removes the robots.txt file.
#
# == Todo
# 
# (nil)
#

namespace :robots do

  desc <<-DESC
    Add a robots.txt to the default release for disallowing robots.

  DESC
  task :add_disallow_robots do
    system "echo 'User-agent: * \nDisallow: /' > #{latest_release}/robots.txt"
  end

  desc <<-DESC
    Remove the robots.txt file created by add_disallow_robots.

  DESC
  task :remove_robots do
   run "#{try_sudo} rm -rf #{latest_release}/robots.txt"
  end
end