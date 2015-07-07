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

def detected_sake_path
  fetch(:sake_path, 'framework/sake')
  # return @sake_bin_path if @sake_bin_path # Return any pre-calculated path

  # try_in_preference_order = [fetch(:sake_path), 'sake', "#{latest_release}/framework/sake"]

  # try_in_preference_order.each do |bin_path|
  #   next if bin_path.nil?
  #   if remote_command_exists?(bin_path)
  #     @sake_bin_path = bin_path
  #     return @sake_bin_path
  #   end
  # end
  # false
end

def local_file_exists?(full_path)
  File.exist?(full_path)
end

def directory_exists?(directory)
  File.directory?(directory)
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
