# 
# Generic Helpers that are used across test scenarios
#
Then(/^(\S*) should be on the remote$/) do |file|
  expect(@deploy.file_exists_on_server?(file)).to be_true
end

Then(/^File from remote should at (\S*)$/) do |file|
  expect(@deploy.file_exists_locally?(file))
end