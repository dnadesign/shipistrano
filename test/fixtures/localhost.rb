set :application, "test"

role :web, 'localhost'
role :app, 'localhost'
role :db, 'localhost'

set :deploy_to, '/path/to/production/app'
