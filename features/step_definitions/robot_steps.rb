#
# App with robots
#
Given(/^I am deploying a basic app with robots$/) do
  @deploy.template = 'robots.erb'
  @deploy.do("robot_basic", "robot_tests")
end


Then(/^a robots\.txt file should exist with Disallow$/) do
  path = @deploy.path_in_release("robots.txt")

  expect(File.read(path)).to eq("User-agent: * \nDisallow: /\n")
end
