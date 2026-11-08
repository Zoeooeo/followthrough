Feature: Create a shared profile for a loved one
  As an adult child of a nursing home resident
  So that my family can track her care in one place
  I want to create one profile for my mother

  Scenario: Create a profile
    Given I am on the home page
    When I follow "Add a loved one"
    And I fill in "Name" with "Linda Chen"
    And I fill in "Facility" with "Greenview Nursing Home"
    And I fill in "Room" with "214"
    And I press "Create profile"
    Then I should see "Profile created for Linda Chen."
    And I should see "Maple Grove · Room 214"
    And I should see "Signal Card"

  Scenario: A profile needs a name
    Given I am on the home page
    When I follow "Add a loved one"
    And I press "Create profile"
    Then I should see "Name can't be blank"

  Scenario: See every loved one on the home page
    Given a resident "Linda Chen" exists
    And a resident "Robert Lee" exists
    When I go to the home page
    Then I should see "Linda Chen"
    And I should see "Robert Lee"
