# 
# Generic Helpers that are used across test scenarios
#
When(/^I run cap (.*)$/) do |op|
  Dir.chdir(@deploy.app_dir) do
    system "cap " + op
  end
end

When(/^I add (\S*) remotely$/) do |file|
  @deploy.execute_remotely("touch #{file}")
end

When(/^I add (\S*) locally$/) do |file|
  @deploy.execute_locally("touch #{file}")
end
