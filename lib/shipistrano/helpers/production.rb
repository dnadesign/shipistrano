#
# DNA Shipistrano
#
# = Production
#
# Contains helpers for managing a deploy that has a 'production' folder on top
# of the current folder. For smaller setups, we use this over a dual stream
# Capistrano setup (prod / stage environments with separate releases).
#
# == Variables
#
# == Tasks
#
# - *publish:code* copies the latest release to a `production_folder`
#
# == Todo
#
# - Tests
# - Document behaviour with shared assets, backup live assets vs staging

set :production_folder, fetch(:production_folder, "#{deploy_to}production")
set :has_production, true

namespace :publish do

  desc <<-DESC
    Copies the current deployed version to a production folder. A backup of the
    current site is saved to backup

  DESC
  task :code do
    run "if [ -d #{deploy_to}/backup ]; then #{try_sudo} rm -rf #{deploy_to}backup; fi"
    run "if [ -d #{production_folder} ]; then #{try_sudo} mv #{production_folder} #{deploy_to}backup; fi"
    run "#{try_sudo} cp -R #{deploy_to}current/ #{production_folder}"
  end
end