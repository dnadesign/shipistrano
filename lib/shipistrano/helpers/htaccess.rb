#
# DNA Shipistrano
#
# = Htaccess
#
# Provides ways of adjusting the .htaccess file
#
# == Variables
#
# - *auth_user* username for basic auth
# - *auth_pass* password for basic auth
# - *auth_folder* folder to protect auth
#
# == Tasks
#
# - *htaccess:auth:protect* add a htpasswd protection to the server.
# - *htaccess:auth:unprotect* remove htpasswd protection
# - *htaccess:rewrite_base* add a rewrite base /
#

namespace :htaccess do
  namespace :auth do

    desc <<-DESC
      Protect a given folder. Use set :auth_folder to protect.

    DESC
    task :protect do
      run "#{try_sudo} htpasswd -nb #{auth_user} '#{auth_pass}' > #{auth_folder}/.htpasswd"
      backup_file("#{auth_folder}/.htaccess")

      prepend_to_file(
        "#{auth_folder}/.htaccess",
        "AuthType Basic\\nAuthName #{app}\\nAuthUserFile #{auth_folder}/.htpasswd\\nRequire User #{auth_user}\\n"
      )
    end

    desc <<-DESC
      Unprotect latest version.

    DESC
    task :unprotect_release do
      run "if [ -f #{auth_folder}/.htaccess.backup ]; then #{try_sudo} rm -rf #{auth_folder}/.htaccess && cp #{auth_folder}/.htaccess.backup #{auth_folder}/.htaccess; fi"
    end

    desc <<-DESC
      Unprotect latest version.

    DESC
    task :unprotect_production do
      run "if [ -f #{production_folder}/.htaccess.backup ]; then #{try_sudo} rm -rf #{production_folder}/.htaccess && cp #{production_folder}/.htaccess.backup #{production_folder}/.htaccess; fi"
    end
  end

  desc <<-DESC
    Rewrite base in htaccess file to /.

  DESC
  task :rewrite_base do
    append_to_file("#{latest_release}/.htaccess", "RewriteBase /")
  end

  def prepend_to_file(filename, str)
    run "echo -e \"#{str}\"|cat - #{filename} > /tmp/out && mv /tmp/out #{filename}"
  end

  def append_to_file(filename, str)
    run "echo -e \"#{str}\" >> #{filename}"
  end

  def backup_file(filename)
    run "#{try_sudo} cp #{filename} #{filename}.backup"
  end
end