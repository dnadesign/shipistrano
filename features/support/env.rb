require 'spec'
require 'erb'
require 'etc'

require File.expand_path(File.join(File.dirname(__FILE__), "deploy_manager.rb"));

deploy = DeployManager.new(
  File.join(Dir.pwd, "test_files")
)

Before do
  # before each scenario.
  @deploy = deploy
end
