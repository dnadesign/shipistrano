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
set :app, fetch(:app, "preview.dna.co.nz")
set :ip, fetch(:ip, "120.138.30.185")
set :deploy_to, fetch(:deploy_to, "#{deploy_to}#{deploy_code}")
set :auth_user, fetch(:auth_user, "#{deploy_code}")
set :auth_pass, fetch(:auth_pass, "#{deploy_pass}")