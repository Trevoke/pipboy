Feature: Backing up a file
    As a user
    I want to back up a file
    So everything is in one place

  Background:
    Given the user's home directory is clean
    And the pipboy's directory is clean

  Scenario: Backing up a file
    Given a file named ".bashrc" in my home directory
    When I type "pipboy watch ~/.bashrc"
    Then ".bashrc" in my home directory should now be a symlink
    And  ".bashrc" should be in the config directory

#  Scenario: Backing up a file that is already watched
#    Given a file named ".bashrc" in my "~/config" directory
#    And a symlink to ".bashrc" in the config directory
#    When I type "pipboy watch .bashrc"
#    Then ".bashrc" should now be a symlink
#    And  ".bashrc" should be in the "~/config" directory
#    And I should get a message "This file is already watched"

#  Scenario: Backing up a file that already exists and is different
#    Given a file named ".bashrc" in my "~/config" directory
#    And a different file named ".bashrc" in my "~/" directory
#    When I type "pipboy watch .bashrc"
#    Then there should be an error "DifferentFileExists"
