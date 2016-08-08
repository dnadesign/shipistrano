#
# DNA Shipistrano
#
# =	Ghost Inspector
#
# == Variables
#
# *ghost_inspector_api_key* The account API key to run the test
# *ghost_inspector_suite_id* The suite of tests to run
#
# == Tasks
#
# *execute* runs the test suite
#
#
namespace :ghost do

  desc <<-DESC
  	Runs the suite given in a new process in order to not delay
  DESC
  task :execute do 
  	if(fetch(:ghost_inspector_suite_id, false) != false) then
    	system "curl -v https://api.ghostinspector.com/v1/suites/#{ghost_inspector_suite_id}/execute/?apiKey=#{ghost_inspector_api_key} > /dev/null 2>&1 &"
    end
  end
end