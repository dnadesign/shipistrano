#
# DNA Sinkistrano
#
# Basic Auth - adds basic auth to the environments. By default this covers 
# the current release, optionally can protect the production environment as
# well.
#
# Requires:
# => auth_user
# => auth_pass
# => auth_folder
#
# Provides:
# => auth:protect
#
# Copyright (c) 2013, DNA Designed Communications Limited
# All rights reserved.

namespace :auth do
  desc "Protect a given folder. Use set :auth_folder to protect"
  task :protect do
    run "#{try_sudo} rm -rf /tmp/.htpasswd"
    run "htpasswd -nb #{auth_user} '#{auth_pass}' > /tmp/.htpasswd"
    run "#{try_sudo} rm -rf /tmp/.htaccess"
    run "#{try_sudo} cp #{auth_folder}/.htaccess #{auth_folder}/.htaccess.backup"
    run "echo 'AuthType Basic\\nAuthName #{app}\\nAuthUserFile #{auth_folder}/.htpasswd\\nRequire User #{auth_user}\\n'|cat - #{auth_folder}/.htaccess > /tmp/.htaccess"
    run "#{try_sudo} mv /tmp/.htaccess #{auth_folder}/.htaccess"
    run "#{try_sudo} mv /tmp/.htpasswd #{auth_folder}/.htpasswd"
  end
  
  desc "Unprotect latest version."
  task :unprotect_release do
    run "if [ -f #{auth_folder}/.htaccess.backup ]; then #{try_sudo} rm -rf #{auth_folder}/.htaccess && cp #{auth_folder}/.htaccess.backup #{auth_folder}/.htaccess; fi"
  end
end