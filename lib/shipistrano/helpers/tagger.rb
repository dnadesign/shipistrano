#
# DNA Shipistrano
#
# = Tagger
#
# Tags the release in git. Uses the format r2015-07-27-115728. Include this in 
# your cap file such as
#
# after('deploy:update', 'tagger:tag')

namespace :tagger do
	task :tag, :on_error => :continue do
		user = `git config --get user.name`.chomp
		email = `git config --get user.email`.chomp
		
		puts `git tag r#{current_time} #{current_revision} -m "Deploy by #{user} <#{email}>"`
		puts `git push --tags origin`
	end
end