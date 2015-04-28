## slack notification requires:
# set :slack_channel
# set :slack_team
# set :slack_token
# set :stage, "production"

class ShipistranoSlack
  require 'net/http'

  def self.post_to_slack(slack_team, slack_token, slack_channel, message)
    uri = URI(URI.encode("https://#{slack_team}.slack.com/services/hooks/slackbot?token=#{slack_token}&channel=##{slack_channel}"))

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request_post uri.request_uri, message
    end
  end

end

namespace :slack do
  task :prenotify do
    user = `whoami`.chomp.split(".").map(&:capitalize).join(' ')
    revision = `cat #{local_cache}/REVISION`.chomp
    message = "#{user} is deploying #{app} version #{revision} to #{stage}"

    ShipistranoSlack.post_to_slack(slack_team, slack_token, slack_channel, message)
  end

  task :postnotify do
    user = `whoami`.chomp.split(".").map(&:capitalize).join(' ')
    revision = `cat #{local_cache}/REVISION`.chomp
    message = "#{user} has deployed #{app} version #{revision} to #{stage}"

    ShipistranoSlack.post_to_slack(slack_team, slack_token, slack_channel, message)
  end
end

before 'deploy', 'slack:prenotify'

after 'deploy:cleanup', 'slack:postnotify'
