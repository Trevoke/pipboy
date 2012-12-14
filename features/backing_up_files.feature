Feature: Backing up a file
  As a user
  I want to back up a file
  So everything is in one place

  Scenario: Backing up a file
    Given a file named ".bashrc" in my home directory
    When I type "pipboy watch .bashrc"
    Then .bashrc should now be a symlink
    And the file should be in the "~/config" directory
