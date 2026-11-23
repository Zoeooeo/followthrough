Feature: Log a visit
  As a relative who just visited Mom
  So that the next visitor knows how she has been and whether reported fixes held
  I want to record how she seemed, which signals I noticed, what I saw, and which fixes I checked, all in one visit log

  Background:
    Given I am signed in as "Amy"
    And a resident "Linda Chen" exists
    And I am in the family of "Linda Chen"
    And "Linda Chen" has a signal "Thirst"

  Scenario: Log a visit
    Given I am on the page for resident "Linda Chen"
    When I follow "Log a visit"
    And I choose "Okay"
    And I check "Thirst"
    And I fill in "What did you see?" with "Hands tucked under her arms. Ate most of lunch."
    And I press "Save visit"
    Then I should see "Visit saved."
    And I should see "Okay"
    And I should see "Thirst"
    And I should see "Ate most of lunch."

  Scenario: Recent visits show on the profile
    Given "Amy" logged a visit to "Linda Chen"
    When I go to the page for resident "Linda Chen"
    Then I should see "Amy" in the recent visits
    And I should see "Good" in the recent visits

  Scenario: Open a concern from a visit
    Given "Amy" logged a visit to "Linda Chen"
    And I am on the latest visit to "Linda Chen"
    When I follow "Open a concern from this visit"
    And I fill in "Problem" with "Room too cold at night"
    And I fill in "What fixed looks like" with "Window closed and an extra blanket"
    And I press "Open concern"
    Then I should see "Concern opened."
    And I should see "Noticed during"

  Scenario: A visit needs a mood
    Given I am on the new visit page for "Linda Chen"
    When I press "Save visit"
    Then I should see "Mood must be Good, Okay, or Not good"

  Scenario: A visit cannot be in the future
    Given I am on the new visit page for "Linda Chen"
    When I fill in "Visit date" with "2999-01-01"
    And I choose "Good"
    And I press "Save visit"
    Then I should see "Visit date can't be in the future"

  Scenario: My rechecks for this resident show up when I log a visit
    Given "Linda Chen" has a concern "Water cup out of reach" opened by "David"
    And staff reported "Water cup out of reach" as fixed and assigned the recheck to "Amy"
    When I go to the new visit page for "Linda Chen"
    Then I should see "1 recheck for you on this visit"
    And I should see "Water cup out of reach" in the visit checks

  Scenario: A visit with nothing to check has no recheck section
    When I go to the new visit page for "Linda Chen"
    Then I should not see "Check fixes on this visit"
