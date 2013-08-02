#
# Helper class for managing 'fake' deployments locally for the cucumber testing.
#
# Structure of a deploy test files is as follows:
# 
#  test_files => ['apps', 'deployed', 'repos']
#
# Each deployment type has it's own folder within each of those to prevent
# populating between tests
#
class DeployManager

  attr_accessor :template
  attr_accessor :post_prep
  attr_accessor :post_deploy

  attr_reader :repo_dir
  attr_reader :app_dir
  attr_reader :deploy_dir
  attr_reader :deployed_apps

  def initialize(testDir)
    @test_files_dir = testDir
    @deployed_apps = @post_prep = @post_deploy = []


    # what to run after the folder's cap file has been set
    @post_deploy_defaults = [
      %Q{cap deploy:setup},
      %Q{cap deploy}
    ]

    FileUtils.rm_r(@test_files_dir) if File.exists?(@test_files_dir)
    FileUtils.mkdir_p(@test_files_dir)
  end

  # executes a command in the latest release directory
  def execute_remotely(command) 
    Dir.chdir(@deploy_dir) do
      Dir.chdir('current') do
        system command
      end
    end
  end

  # executes a command in the application
  def execute_locally(command)
    Dir.chdir(@app_dir) do
      system command
    end
  end

  # retrieves the file path of the file in the latest release
  def path_in_release(file)
    return File.join(@deploy_dir, "current", file)
  end

  # File exists on the production version
  def file_exists_on_server?(filepath)
    Dir.chdir(@deploy_dir) do
      return File.exists?(filepath)
    end
  end

  # File exists on the local version
  def file_exists_locally?(filepath)
    return File.exists?(filepath)
  end

  # do a deployment
  def do(name, destination)
    @app_dir = File.join(@test_files_dir, "apps", name)
    @repo_dir = File.join(@test_files_dir, "repos", name)
    @deploy_dir = File.join(@test_files_dir, "deployed", destination)
    
    # default operations run on a folder
    @prep_ops_default = [
      %Q{git init},
      %Q{echo 'welcome to test' > README.md},
      %Q{git add .},
      %Q{git commit -a -m "first commit"},
      %Q{git remote add origin file://#{@repo_dir}},
      %Q{git push origin master}
    ]

    FileUtils.mkdir_p @repo_dir
    FileUtils.mkdir_p @app_dir

    #
    if not @deployed_apps.include? name
      deploy_fresh_project()
    else
      redeploy_existing_project()
    end

    clean_up()

    @deployed_apps.push name
  end

  # deploy a fresh new project
  def deploy_fresh_project()
    Dir.chdir(@repo_dir) do
      system "git --bare init"
    end

    Dir.chdir(@app_dir) do
      ops = @prep_ops_default | @post_prep

      ops.each do |command|
        system command
      end
    end

    populate_deploy_capfile()

    Dir.chdir(@app_dir) do
      ops = @post_deploy_defaults | @post_deploy

      ops.each do |command|
        system command
      end
    end
  end

  # Generate a cap file for the repo. If a test requires a different capfile
  # to another test then it should push to a different name
  def populate_deploy_capfile()
    deploy_variables = {
      :deploy_to => @deploy_dir,
      :repository => @repo_dir,
      :git_executable => `which git`.strip,
      :assets_folder => 'assets',
      :logged_in_user => Etc.getlogin
    }

    if @template
      template_path = File.expand_path(File.join(__FILE__,  "..", "..", "templates", @template))
    end

    base_path = File.expand_path(File.join(__FILE__,  "..", "..", "templates", 'basic.erb'))

    base_template = ERB.new(File.read(base_path)).result(binding)
    compiled_template = ERB.new(File.read(template_path)).result(binding)

    # Create a cap file
    File.open(File.join(@app_dir, "capfile"), 'w') {|f| 
      f.write base_template
      f.write compiled_template
    }
  end

  # redeploying an existing project. Just run any special commands. A deploy
  # must have the same capfile, if the capfile requires a change then select
  # a different  name
  def redeploy_existing_project()
    # we have deployed the applic
    Dir.chdir(@app_dir) do
      if not @post_prep.empty?
        @post_prep.each do |command|
          system command
        end
      end

      if not @post_deploy.empty?
        @post_deploy.each do |command|
          system command
        end
      end
    end
  end

  # after running the operation, clear the custom values
  def clean_up() 
    @template = "basic.erb"
    @post_prep_ops = []
    @post_deploy_ops = []
  end
end