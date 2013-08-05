Feature: MySQL
  In order to test the MySQL integration of Shipistrano
  As a person who is going to deploy a web application with MySQL
  I want to make sure the MySQL functionality works

  Scenario: User uploads a local MySQL database to remote
    Given I am deploying a basic app with MySQL
    When I run cap mysql:upload
    Then My MySQL database should be uploaded to the remote
    Then The MySQL backups folder on remote should contain a backup

  Scenario: User downloads the main MySQL database
    Given The production MySQL database has been populated
    Given I have made MySQL changes in production
    When I run cap mysql:download
    Then The remote MySQL database has been downloaded to my machine