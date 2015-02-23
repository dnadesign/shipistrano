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
set :use_sudo, false
set :user, "deploy"
set :mysql_database,    "deploy_#{mysql_database}"
set :app, "preview.dna.co.nz/#{deploy_code}"
set :application, "#{app}"
set :ip, "120.138.30.185"
set :deploy_to, "/srv/preview.dna.co.nz/site_files/#{deploy_code}/"
set :site_symlink, "/srv/preview.dna.co.nz/site_symlinks/#{deploy_code}"
set :auth_user, "#{deploy_code}"
set :auth_pass, "#{deploy_pass}"
set :keep_releases, 2
set :ss_version, 3
set :ss_preview, true
after('deploy:update', 'preview_setup:create_htaccess')
after('deploy:update', 'htaccess:auth:protect')
after('deploy:update', 'deploy:cleanup')
after('silverstripe:fix_owner_cache_folder', 'silverstripe:fix_owner_cache_folder_preview')


namespace :preview_setup do

  desc <<-DESC
    Setup all the folders that are needed

  DESC
  task :setup_dir do
    run "#{try_sudo} mkdir -p #{deploy_to}"
    run "#{try_sudo} mkdir -p #{deploy_to}shared"
    run "#{try_sudo} mkdir -p #{deploy_to}releases"
    run "#{try_sudo} mkdir -p #{deploy_to}shared/mysql_uploads"
    run "#{try_sudo} mkdir -p #{deploy_to}shared/solr"
    run "#{try_sudo} mkdir -p #{deploy_to}shared/mysql_backups"
    run "#{try_sudo} chown #{user}:#{group} #{deploy_to}"
    run "#{try_sudo} chown #{user}:#{group} #{deploy_to}shared"
    run "#{try_sudo} chown #{user}:#{group} #{deploy_to}releases"
    run "#{try_sudo} chown #{user}:#{group} #{deploy_to}shared/mysql_uploads"
    run "#{try_sudo} chown #{user}:#{group} #{deploy_to}shared/solr"
    run "#{try_sudo} chown #{user}:#{group} #{deploy_to}shared/mysql_backups"
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
# gzip text documents: html,css,xml,javascript,svg
AddOutputFilterByType DEFLATE text/html text/css text/plain text/xml image/svg+xml application/x-javascript application/javascript
BrowserMatch ^Mozilla/4 gzip-only-text/html
BrowserMatch ^Mozilla/4\.0[678] no-gzip
BrowserMatch \bMSIE !no-gzip !gzip-only-text/html

ErrorDocument 404 /assets/error-404.html
ErrorDocument 500 /assets/error-500.html

### SILVERSTRIPE START ###
<Files *.ss>
    Require host 127.0.0.1
</Files>

<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /#{deploy_code}

    RewriteCond %{REQUEST_URI} !/_html*
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
# gzip text documents: html,css,xml,javascript,svg
AddOutputFilterByType DEFLATE text/html text/css text/plain text/xml image/svg+xml application/x-javascript application/javascript
BrowserMatch ^Mozilla/4 gzip-only-text/html
BrowserMatch ^Mozilla/4\.0[678] no-gzip
BrowserMatch \bMSIE !no-gzip !gzip-only-text/html

ErrorDocument 404 /assets/error-404.html
ErrorDocument 500 /assets/error-500.html

### SILVERSTRIPE START ###
<Files *.ss>
    Require host 127.0.0.1
</Files>

<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /#{deploy_code}

    RewriteCond %{REQUEST_URI} !/_html*
    RewriteCond %{REQUEST_URI} ^(.*)$
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule .* framework/main.php?url=%1&%{QUERY_STRING} [L]
</IfModule>
### SILVERSTRIPE END ###
    HTA

    run "if [ -f #{latest_release}/.htaccess ]; then mv #{latest_release}/.htaccess #{latest_release}/.htaccess.normal; fi"

    File.write("#{local_cache}/.htaccess", create_ht)
    system "rsync -rv #{local_cache}/.htaccess #{user}@#{ip}:#{latest_release}/.htaccess"
  end

  def setup_htaccess()
    create_ht = <<-HTA
# gzip text documents: html,css,xml,javascript,svg
AddOutputFilterByType DEFLATE text/html text/css text/plain text/xml image/svg+xml application/x-javascript application/javascript
BrowserMatch ^Mozilla/4 gzip-only-text/html
BrowserMatch ^Mozilla/4\.0[678] no-gzip
BrowserMatch \bMSIE !no-gzip !gzip-only-text/html
    HTA

    run "if [ -f #{latest_release}/.htaccess ]; then mv #{latest_release}/.htaccess #{latest_release}/.htaccess.normal; fi"
    put create_ht, "#{latest_release}/.htaccess"
  end


  desc <<-DESC
    Delete standard .htaccess and create standard ss one

  DESC
  task :create_htaccess do
    # Use fetch to set the default value, don't set the value outright
    if !fetch(:has_ss, true)
      setup_htaccess()
    elsif ss_version == 3
      setup_htaccess_ss3()
    else
      setup_htaccess_ss2()
    end
  end
end
