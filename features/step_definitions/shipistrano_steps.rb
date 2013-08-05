require File.expand_path(File.join(
	File.dirname(__FILE__), "..", "..", "lib", "shipistrano", "helpers", "helpers.rb"
));

Given(/^I am deploying a basic app with helpers attached$/) do
  @deploy.template = "helpers.erb"
  @deploy.do("helpers", "helper_test")
end