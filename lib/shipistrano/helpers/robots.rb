# 
# DNA Shipistrano
#
# = Robots
#
# Misc tasks around dealing with Robot files. Mostly we just add them to disable
# indexing sites before we've launched them fully
#
# == Variable Exports
#
# (nil)
#
# == Task Exports
#
# *add_disallow_robots* add a robots.txt to block search agents for the latest
# release.
# *remove_robots* removes the robots.txt file
#
# == Todo
# 
# (nil)
#

namespace :robots do

  #
  # Add a disallow robots.txt file to the last release. Used if needing
  # to push private projects or staging applications
  #
  desc "Add a robots.txt to the default release for disallowing robots."
  task :add_disallow_robots do
    system "echo 'User-agent: * \nDisallow: /' > #{latest_release}/robots.txt"
  end

  #
  # Removes the robots.txt file. See add_disallow_robots
  #
  desc "Remove the robots.txt file created by add_disallow_robots"
  task :remove_robots do
   run "#{try_sudo} rm -rf #{latest_release}/robots.txt"
  end
end