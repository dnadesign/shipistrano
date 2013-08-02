# 
# Generic Helpers that are used across test scenarios
#
Given(/^I am deploying a basic app$/) do
  @deploy.do("basic", "core_tests")
end