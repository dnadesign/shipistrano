Feature: Core
  In order to test the core tasks of Shipistrano
  As a person who is going to deploy a web application
  I want to make sure everything works

  Scenario: User deploys
    Given I am deploying a basic app
    When I run add_disallow_robots
    Then a robots.txt file should exist with Disallow