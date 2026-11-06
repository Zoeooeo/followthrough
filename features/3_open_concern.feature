Feature: Open a concern after a visit
  As a family member who noticed a problem during a visit
  So that my siblings and staff know exactly what needs to change
  I want to open a concern with a clear goal for what "fixed" looks like

  Background:
    Given a resident "Linda Chen" exists
    And "Linda Chen" has a signal "Thirst"

  Scenario: Open a concern linked to a signal
    Given I am on the page for resident "Linda Chen"
    When I follow "Open a concern"
    And I fill in "Problem" with "Water cup out of reach"
    And I fill in "What fixed looks like" with "Cup on her right side, at least half full"
    And I fill in "Opened by" with "David"
    And I select "Thirst" from "Related signal"
    And I press "Open concern"
    Then I should see "Concern opened."
    And the status should be "Open"
    And I should see "Cup on her right side, at least half full"
    And I should see "Opened by David"

  Scenario: A concern needs a goal for what "fixed" looks like
    Given I am on the page for resident "Linda Chen"
    When I follow "Open a concern"
    And I fill in "Problem" with "Room too cold at night"
    And I fill in "Opened by" with "Amy"
    And I press "Open concern"
    Then I should see "What fixed looks like can't be blank"

  Scenario: Open concerns appear on the profile
    Given "Linda Chen" has a concern "Water cup out of reach" opened by "David"
    When I go to the page for resident "Linda Chen"
    Then "Water cup out of reach" should be listed as "Open"

  Scenario: A new concern cannot be rechecked before staff respond
    Given "Linda Chen" has a concern "Water cup out of reach" opened by "David"
    When I go to the concern page for "Water cup out of reach"
    Then I should see the staff response form
    And I should not see the recheck form
