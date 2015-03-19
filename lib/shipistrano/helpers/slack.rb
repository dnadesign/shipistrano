## slack notification requires:
# set :slack_channel
# set :slack_team
# set :slack_token
# set :stage, "production"

namespace :slack do
  task :notify do
    uri = URI(URI.encode("https://#{slack_team}.slack.com/services/hooks/slackbot?token=#{slack_token}&channel=#{slack_channel}"))

    user = `whoami`.chomp.split(".").map(&:capitalize).join(' ')
    revision = `cat #{local_cache}/REVISION`.chomp
    message = "#{user} has deployed #{app} version #{revision} to #{stage}"

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request_post uri.request_uri, text
    end
  end
end

after 'deploy:create_symlink', 'slack:notify'
