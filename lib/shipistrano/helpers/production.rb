#
# DNA Shipistrano
#
# Production - contains helpers for managing a deploy that has a 'production' 
# folder on top of the current folder. I recommend this over a dual stream 
# capistrano setup (prod / stage environments with separate releases).
#
# Adds:
# => cap publish:code
#
# Copyright (c) 2013, DNA Designed Communications Limited
# All rights reserved.

namespace :publish do
  
  desc "Copys the current deployed version to a production folder. A backup of 
        the current site is saved to backup/"
  task :code do
    run "if [ -d #{deploy_to}/backup ]; then rm -rf #{deploy_to}/backup; fi"
    run "if [ -d #{deploy_to}/production ]; then mv #{deploy_to}/production #{deploy_to}/backup; fi"
    run "cp -R #{latest_release} #{deploy_to}/production"
    
    publish.symlink_assets
    deploy.cleanup
  end
  
  desc "Symlinks the assets from the shared folder to the production release"
  task :symlink_assets do
    run "ln -nfs #{shared_path}/#{assets_folder} #{deploy_to}/production/#{assets_path}#{assets_folder}"
    
    ship.fix_permissions
  end
end