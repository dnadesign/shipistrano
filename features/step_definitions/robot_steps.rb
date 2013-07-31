When(/^I run add_disallow_robots$/) do
  Dir.chdir(@app_dir) do
    system "cap core:add_disallow_robots"
  end
end

Then(/^a robots\.txt file should exist with Disallow$/) do
  path = File.join(@deploy_dir, "current/robots.txt")

  expect(File.read(path)).to eq("User-agent: * \nDisallow: /\n")
end
