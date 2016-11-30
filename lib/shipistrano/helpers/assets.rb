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

  desc <<-DESC
    Symlinks the assets from the shared folder to the latest release.

  DESC
  task :symlink do
    # Remove the existing list
    run "rm -rf #{latest_release}/#{asset_location}"

    # if the assets folder doesn't exist on the remote, add it
    run "mkdir -p #{user}:#{group} #{shared_path}/#{assets_folder}"
    run "ln -nfs #{shared_path}/#{assets_folder} #{latest_release}/#{asset_location}"

    #assets.fix_permissions
	end

  desc <<-DESC
    Uploads the assets from the dev copy to the remote server.

  DESC
  task :upload do
    system "rsync -rv #{asset_location}/ #{user}@#{ip}:#{deploy_to}/shared/#{assets_folder}"

    assets.fix_permissions
  end

  desc <<-DESC
    Downloads the asset folder from the remote to the local server

  DESC
  task :download do
    system "rsync -rv #{assets_exclude} #{user}@#{ip}:#{shared_path}/#{assets_folder}/#{assets_subfolder} #{assets_folder}/#{assets_subfolder}"
    system "sudo chmod -R 775 assets/"
  end

  desc <<-DESC
    Fix the permissions on the assets folder. If we cannot change the permissions
    continue with the deploy.

  DESC
  task :fix_permissions, :on_error => :continue do
    if fetch(:skip_fix_permissions, false) == false then
      run "#{try_sudo} mkdir -p #{shared_path}/#{assets_folder}"
      run "#{try_sudo} chown -R #{user}:#{group} #{shared_path}/#{assets_folder}"
      run "#{try_sudo} chmod -R 775 #{shared_path}/#{assets_folder}"
    end
  end

  #
  # Returns the asset folder location. Assumes location is the same locally and
  # remotely
  #
  def asset_location()
    if fetch(:assets_path, "") != "" then
      return asset_location = "#{assets_path}/#{assets_folder}"
    end

    return asset_location = "#{assets_folder}"
  end
end

after('deploy:finalize_update', 'assets:symlink')
