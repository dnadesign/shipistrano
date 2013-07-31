#
# Basic app has just the barebones. We often use it for simple static webpages
# or Jekyll blogs.
# 
Given(/^I am deploying a basic app$/) do
  @deploy_dir = File.join(@test_files_dir, "basic", "deployed")
  
  FileUtils.mkdir_p @repo_dir
  Dir.chdir(@repo_dir) do
    system "git --bare init"
  end

  FileUtils.mkdir_p @app_dir
  Dir.chdir(@app_dir) do
    [
      %Q{git init},
      %Q{touch README.md},
      %Q{git add .},
      %Q{git commit -m "first commit"},
      %Q{git remote add origin file://#{@repo_dir}},
      %Q{git push origin master}
    ].each do |command|
      system command
    end
  end
  
  # Write a custom deploy file to the app, using an ERB template
  deploy_variables = {
    :deploy_to => @deploy_dir,
    :repository => @repo_dir,
    :git_executable => `which git`.strip,
    :logged_in_user => Etc.getlogin
  }

  template_path     = File.expand_path(File.join(__FILE__, "..", "..", "templates", "basic.erb"))
  compiled_template = ERB.new(File.read(template_path)).result(binding)

  File.open(File.join(@app_dir, "capfile"), 'w') {|f| 
    f.write compiled_template
  }

  # run the setup and do a quick first deploy
  Dir.chdir(@app_dir) do
    [
      %Q{cap deploy:setup},
      %Q{cap deploy}
    ].each do |command|
      system command
    end
  end
end