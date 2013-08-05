# 
# DNA Shipistrano
#
# Misc ruby and capistrano helper functions for use throughout the scripts and 
# other helpers.
#

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
  File.exist?(full_path)
end

def remote_command_exists?(command)
  'true' == capture("if [ -x \"$(which #{command})\" ]; then echo 'true'; fi").strip
end

def local_command_exists?(command)
  system("which #{ command} > /dev/null 2>&1")
end

def current_time
  Time.now.strftime("%Y-%m-%d-%H%M%S")
end
