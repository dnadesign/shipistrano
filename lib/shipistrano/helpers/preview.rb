#
# DNA Shipistrano
#
# = Preview.dna.co.nz
#
# Contains helpers for managing a deploy that has a 'preview' folder on preview.dna.co.nz
#
# == Variables
#
# == Tasks
#
# == Todo
#
# - Tests
# - Document behaviour with shared assets, backup live assets vs staging
#
set :app, "preview.dna.co.nz"
set :application, :app
set :ip, "120.138.30.185"
set :deploy_to, "/srv/preview.dna.co.nz/site_files/#{deploy_code}/"
set :site_symlink, "/srv/preview.dna.co.nz/site_symlinks/#{deploy_code}"
set :auth_user, "#{deploy_code}"
set :auth_pass, "#{deploy_pass}"
set :keep_releases, 2
after('deploy:update', 'preview_setup:create_htaccess')
after('deploy:update', 'htaccess:auth:protect')
after('deploy:update', 'deploy:cleanup')


namespace :preview_setup do

  desc <<-DESC
    Fix the permissions on the assets folder

  DESC
  task :setup_dir do
    run "#{try_sudo} mkdir -p #{deploy_to}"
    run "#{try_sudo} mkdir -p #{deploy_to}shared"
    run "#{try_sudo} mkdir -p #{deploy_to}releases"
    run "#{try_sudo} chown #{user}:#{group} #{deploy_to}"
    run "#{try_sudo} chown #{user}:#{group} #{deploy_to}shared"
    run "#{try_sudo} chown #{user}:#{group} #{deploy_to}releases"
  end

  desc <<-DESC
    Add symlink to symlinks folder outside the site_files folder

  DESC
  task :additional_symlink do
    run "rm -f #{site_symlink}"
    run "ln -s #{release_path} #{site_symlink}"
  end

  after('deploy:create_symlink', 'preview_setup:additional_symlink')


  def setup_htaccess_ss2()
    create_ht = <<-HTA
### SILVERSTRIPE START ###
<Files *.ss>
        Order deny,allow
        Deny from all
        Allow from 127.0.0.1
</Files>

<IfModule mod_rewrite.c>
        RewriteEngine On
        RewriteBase /#{deploy_code}

        RewriteCond %{REQUEST_URI} ^(.*)$
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule .* sapphire/main.php?url=%1&%{QUERY_STRING} [L]

</IfModule>
### SILVERSTRIPE END ###
    HTA

    run "if [ -f #{latest_release}/.htaccess ]; then mv #{latest_release}/.htaccess #{latest_release}/.htaccess.normal; fi"
    put create_ht, "#{latest_release}/.htaccess"
  end


  def setup_htaccess_ss3()
    create_ht = <<-HTA
### SILVERSTRIPE START ###
<Files *.ss>
        Order deny,allow
        Deny from all
        Allow from 127.0.0.1
</Files>

<IfModule mod_rewrite.c>
        RewriteEngine On
        RewriteBase /#{deploy_code}

        RewriteCond %{REQUEST_URI} ^(.*)$
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule .* framework/main.php?url=%1&%{QUERY_STRING} [L]

</IfModule>
### SILVERSTRIPE END ###
    HTA

    run "if [ -f #{deploy_to}.htaccess ]; then rm #{deploy_to}.htaccess; fi"
    put create_ht, "#{deploy_to}.htaccess"
  end


  desc <<-DESC
    Delete standard .htaccess and create standard ss one

  DESC
  task :create_htaccess do
    if is_ss2
      setup_htaccess_ss2()
    elsif is_ss3
      setup_htaccess_ss3()
    end
  end

end