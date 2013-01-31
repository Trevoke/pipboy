Feature: Backing up a file
    As a user
    I want to back up a file
    So I can sleep at night

  # Scenario: Backing up a file
  #   Given a file named ".bashrc" in home
  #   When I type "pipboy watch .bashrc"
  #   Then ".bashrc" in my home directory should now be a symlink
  #   And  ".bashrc" should be in the config directory

  Scenario: The pipboy watches a file
    Given an empty home directory
    And an empty config directory
    And a file named ".bashrc" in the home directory
    When I monitor ".bashrc"
    Then there should be "1" file in the config directory
    And ".bashrc" in the home directory should be a "symlink"
    And ".bashrc" in the home directory should point to the file in the config directory
    And there should be no untracked files in the config repository
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
