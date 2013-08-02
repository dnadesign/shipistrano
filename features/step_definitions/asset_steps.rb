
#
# Basic app with an assets folder. We need to create a new assets folder in
# the project and 
# 
Given(/^I am deploying a basic app with an assets folder$/) do
  @deploy.post_prep = [
    "echo 'assets' > .gitignore",
    "git add .gitignore",
    "git commit .gitignore -m 'Assets should be ignored'",
    "mkdir -p assets",
    "touch assets/file.txt"
  ]

  @deploy.template = "assets.erb"
  @deploy.do("basic_assets", "basic_assets")
end

#
# Basic app with an assets folder in a nested location.
# 
Given(/^I am deploying a basic app with a nested assets folder$/) do
  @deploy.post_prep = [
    "echo '_r/assets' > .gitignore",
    "mkdir -p _r",
    "mkdir -p _r/assets",
    "touch _r/.gitkeep",
    "git add .gitignore",
    "git add _r",
    "git commit -a -m 'Commit new folder and add gitignore'"
  ]

  @deploy.template = "assets.nested.erb"
  @deploy.do("nested_assets", "nested_assets")
end

Then(/^The assets folder from shared is symlinked into the last release$/) do
  Dir.chdir(@deploy.deploy_dir) do
  	expect(File.exists?("current/assets")).to be_true
  	expect(File.realdirpath("current/assets")).to match /shared\/assets$/
  end
end

Then(/^The nested assets folder from shared is symlinked into the last release$/) do
  Dir.chdir(@deploy.deploy_dir) do
  	expect(File.exists?("current/_r/assets")).to be_true
  	expect(File.realdirpath("current/_r/assets")).to match /shared\/assets$/
  end
end