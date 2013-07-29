# DNA Capistrano
#
# Misc ruby and capistrano helper functions for use throughout the core and 
# other helpers.
#
# Copyright (c) 2013, DNA Designed Communications Limited
# All rights reserved.

def pretty_print(msg)
  if logger.level == Capistrano::Logger::IMPORTANT
    pretty_errors
 
    msg = msg.slice(0, 57)
    msg << '.' * (60 - msg.size)
    print msg
  else
    puts msg
  end
end

 
def puts_ok
  if logger.level == Capistrano::Logger::IMPORTANT && !$error
    puts '✔'
  end
 
  $error = false
end


def remote_file_exists?(full_path)
  'true' == capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

def local_file_exists?(full_path)
  system("if [ -e #{full_path} ]; then echo 'true'; fi > /dev/null 2>&1")
end

def remote_command_exists?(command)
  'true' == capture("if [ -x \"$(which #{command})\" ]; then echo 'true'; fi").strip
end

def local_command_exists?(command)
  system("which #{ command} > /dev/null 2>&1")
end