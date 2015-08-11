#
# DNA Shipistrano
#
# = Confirmation
#
# Provides helper functions for asking the user to confirm an operation.
#
# == Tasks
#
# - *php:info*
#
# == Todo
#
# (nil)
#
namespace :confirmation do
  task :ask_deploy_confirmation do
    set(:confirmed) do
      puts <<-WARN
      ========================================================================
      You're about to deploy #{branch} to #{stage} as #{user}
      ========================================================================
      WARN
      answer = Capistrano::CLI.ui.ask "  Are you sure you want to continue? (Y) "
      if answer.upcase == 'Y' then true else false end
    end

    unless fetch(:confirmed)
      puts "\nCancelled!"
      exit
    end
  end

  task :ask_mysql_confirmation do
    set(:confirmed) do
      puts <<-WARN
      ========================================================================
      You're about to upload your local MySQL to #{stage}. You can rollback this
      operation using mysql:upload_revert.
      ========================================================================
      WARN
      answer = Capistrano::CLI.ui.ask "  Are you sure you want to continue? (Y) "
      if answer.upcase == 'Y' then true else false end
    end

    unless fetch(:confirmed)
      puts "\nCancelled!"
      exit
    end
  end

  task :ask_mysql_down_confirmation do
    set(:confirmed) do
      puts <<-WARN
      ========================================================================
      You're about to override your local MySQL with data from #{stage}. You 
      can rollback this operation using mysql:download_revert.
      ========================================================================
      WARN
      answer = Capistrano::CLI.ui.ask "  Are you sure you want to continue? (Y) "
      if answer.upcase == 'Y' then true else false end
    end

    unless fetch(:confirmed)
      puts "\nCancelled!"
      exit
    end
  end

  task :ask_assets_down_confirmation do
    set(:confirmed) do
      puts <<-WARN
      ========================================================================
      You're about to override your local assets with data from #{stage}. You 
      can rollback this operation using assets:download_revert.
      ========================================================================
      WARN
      answer = Capistrano::CLI.ui.ask "  Are you sure you want to continue? (Y) "
      if answer.upcase == 'Y' then true else false end
    end

    unless fetch(:confirmed)
      puts "\nCancelled!"
      exit
    end
  end


  task :ask_assets_confirmation do
    set(:confirmed) do
      puts <<-WARN
      ========================================================================
      You're about to upload your local assets to #{stage}. You can rollback this
      operation using assets:upload_revert.
      ========================================================================
      WARN
      answer = Capistrano::CLI.ui.ask "  Are you sure you want to continue? (Y) "
      if answer.upcase == 'Y' then true else false end
    end

    unless fetch(:confirmed)
      puts "\nCancelled!"
      exit
    end
  end
end

before('deploy', 'confirmation:ask_deploy_confirmation')
before('mysql:upload', 'confirmation:ask_mysql_confirmation')
before('mysql:download', 'confirmation:ask_mysql_down_confirmation')
before('assets:upload', 'confirmation:ask_assets_confirmation')
before('assets:download', 'confirmation:ask_assets_down_confirmation')