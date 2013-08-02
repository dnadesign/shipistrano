Feature: Robots
  In order to test the robot tasks of Shipistrano
  As a person who is going to deploy a web application
  I want to make sure everything works

  Scenario: User deploys
    Given I am deploying a basic app with robots
    When I run cap robots:add_disallow_robots
    Then a robots.txt file should exist with Disallow