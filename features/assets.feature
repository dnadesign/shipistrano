Feature: Assets
  In order to test the asset folder support of Shipistrano
  As a person who is going to deploy a web application with assets
  I want to make sure the assets folder functionality works

  Scenario: User symlinks assets directly
    Given I am deploying a basic app with an assets folder
    When I run cap assets:symlink
    Then The assets folder from shared is symlinked into the last release

  Scenario: User runs a deploy, assets symlinked automatically.
  	Given I am deploying a basic app with an assets folder
  	When I run cap deploy
  	Then The assets folder from shared is symlinked into the last release

  Scenario: User downloads assets
  	Given I am deploying a basic app with an assets folder
  	When I add current/assets/test_prod.txt remotely
  	When I run cap assets:download
  	Then File from remote should at assets/test_prod.txt

  Scenario: User uploads assets
  	Given I am deploying a basic app with an assets folder
  	When I add assets/basic_upload.png locally
  	When I run cap assets:upload
  	Then shared/assets/basic_upload.png should be on the remote
  	Then current/assets/basic_upload.png should be on the remote

  Scenario: User uploads assets with a nested folder
  	Given I am deploying a basic app with a nested assets folder
  	When I add _r/assets/nested_upload.txt locally
  	When I run cap assets:upload
  	Then shared/assets/nested_upload.txt should be on the remote
  	Then current/_r/assets/nested_upload.txt should be on the remote

  Scenario: User runs a deploy, nested assets symlinked automatically 
    Given I am deploying a basic app with a nested assets folder
    When I add _r/assets/nested_upload_deploy.txt locally
    When I run cap assets:upload
    When I run cap deploy
    Then The nested assets folder from shared is symlinked into the last release
    Then current/_r/assets/nested_upload_deploy.txt should be on the remote
