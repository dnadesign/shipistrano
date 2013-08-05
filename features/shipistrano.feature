Feature: Shipistrano Helpers
  In order to test the helper functions of Shipistrano
  As a person who is going to deploy a web application
  I want to make sure each function works

  Scenario: Shipistrano needs to check a remote file
  	Given I am deploying a basic app with helpers attached
    When I add test.txt remotely
    Then cap helpertests:check_file_testtxt should return true
    Then cap helpertests:check_file_testtxtfake should return false
