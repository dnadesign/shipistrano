require 'Open3'

#
# Basic app with an assets folder. We need to create a new assets folder in
# the project and 
# 
Given(/^I am deploying a basic app with MySQL$/) do
  
  mysql_file = File.expand_path(
    File.join(File.dirname(__FILE__), '..', 'templates/mysql_setup.sql')
  )

  # create our local db
  @deploy.post_prep = [
    "mysql < #{mysql_file}",
  ]

  @deploy.template = "mysql.erb"
  @deploy.do("mysql", "mysql")
end

# uploaded the database
Then(/^My MySQL database should be uploaded to the remote$/) do
  stdin, stdout, stderr = Open3.popen3('mysql -e "SHOW DATABASES LIKE \'shipistrano_test_db_uploaded\'"') 

  expect(stdout.read).to eq("Database (shipistrano_test_db_uploaded)\nshipistrano_test_db_uploaded\n")
end

# the server should have a backup with timestamp
Then(/^The MySQL backups folder on remote should contain a backup$/) do
  expect(@deploy.remote_folder_contains_match?(
    "shared/mysql/backups/", 
    "shipistrano_test_db_uploaded_**.sql.gz")
  ).to be_true
end

Given(/^The production MySQL database has been populated$/) do
  puts "Uploading production"
  stdin, stdout, stderr = Open3.popen3('mysql -e "CREATE DATABASE IF NOT EXISTS shipistrano_test_db_uploaded;"')
  puts stdout.read
  stdin, stdout, stderr = Open3.popen3("mysqldump shipistrano_test_db | mysql shipistrano_test_db_uploaded")
  puts stdout.read
end

Given(/^I have made MySQL changes in production$/) do
  puts "Making changes to production"
  stdin, stdout, stderr = Open3.popen3('mysql -D shipistrano_test_db_uploaded -e "INSERT INTO test (message, test) VALUES (\'test changes in production\', \'download_main_db\')";')
  puts stdout.read
end

Then(/^The remote MySQL database has been downloaded to my machine$/) do
  # check the prod properties are in local
  stdin, stdout, stderr = Open3.popen3("mysql -D shipistrano_test_db_uploaded -e 'SELECT message FROM test WHERE test = \"download_main_db\"'")

  expect(stdout.read).to eq("message\ntest changes in production\n")
end