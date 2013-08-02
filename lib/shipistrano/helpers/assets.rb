# 
# DNA Shipistrano
#
# = Assets
#
# Contains general configuration variables and tasks for managing a single asset 
# folder. A asset folder is something that is stored outside of the release and 
# normally resymlinked in after a release.
#
# == Variable Exports
#
# - *assets_path* path relative from project root to the folder containing the 
# assets folder.
# - *assets_folder* name of the assets folder.
# 
# == Task Exports
#
# - *assets:upload* uploads the local assets folder to the remote assets folder.
# - *assets:symlink* symlinks the assets folder into the latest release.
# - *assets:download* download the assets folder to your project.
# - *assets:fix_permissions* fixes the permissions on the assets folder
# 
# == Todo
#
# - Support multiple asset folders
#

namespace :assets do
  #
  # Returns the asset folder location. Assumes location is the same locally and
  # remotely
  #
  def asset_location() 
    if fetch(:assets_path, false) != false then
      return asset_location = "#{assets_path}/#{assets_folder}"
    end

    return asset_location = "#{assets_folder}"
  end

  # 
  # Returns the path to the assets folder 
  #
  # Asset folder should be stored in the shared path and symlinked in when we 
  # need it.
  #
  desc "Symlinks the assets from the shared folder to the latest release"
  task :symlink do
    # Remove the existing list
    run "rm -rf #{latest_release}/#{asset_location}"

    # if the assets folder doesn't exist on the remote, add it
    run "mkdir -p #{shared_path}/#{assets_folder}"
    run "ln -nfs #{shared_path}/#{assets_folder} #{latest_release}/#{asset_location}"

    assets.fix_permissions
	end

  #
  # Uploads the local assets folder up to the shared assets folder.
  #
  desc "Uploads the assets from the dev copy to the remote server."
  task :upload do
    puts "Uploading ","rsync -rv #{asset_location} #{user}@#{ip}:#{deploy_to}/shared/#{assets_folder}"
    system "rsync -rv #{asset_location}/ #{user}@#{ip}:#{deploy_to}/shared/#{assets_folder}"

    assets.fix_permissions
  end

  #
  # Downloads the assets folder from the host to the local dev machine
  #
  desc "Downloads the asset folder from the server to the local directory"
  task :download do
    system "rsync -rv #{user}@#{ip}:#{shared_path}/#{assets_folder}/ #{assets_folder}"
    
    # local user permissions so
    system "chmod -R 775 assets/"
  end

  # 
  # Fixes the permissions on the assets folder.
  #
  desc "Fix the permissions on the assets folder"
  task :fix_permissions do
    run "#{try_sudo} mkdir -p #{shared_path}/#{assets_folder}"
    run "#{try_sudo} chmod -R 775 #{shared_path}/#{assets_folder}"
  end
end

after('deploy:create_symlink', 'assets:symlink')