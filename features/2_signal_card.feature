Feature: Keep a Signal Card
  As a family member
  So that every visitor knows how Mom shows thirst, pain, or distress
  I want to write down each signal and what to check for

  Background:
    Given a resident "Linda Chen" exists

  Scenario: The Signal Card says it is not medical advice
    When I go to the page for resident "Linda Chen"
    Then I should see "Family observations, not medical judgment."

  Scenario: Add a signal
    Given I am on the page for resident "Linda Chen"
    When I follow "Add a signal"
    And I fill in "Need" with "Thirst"
    And I fill in "Shows it by" with "Licks her lips, points at her mouth"
    And I fill in "Check for" with "Cup within reach"
    And I press "Save signal"
    Then I should see "Signal added to the Signal Card."
    And I should see "Licks her lips, points at her mouth"
    And I should see "Cup within reach"

  Scenario: A signal needs all three parts
    Given I am on the page for resident "Linda Chen"
    When I follow "Add a signal"
    And I fill in "Need" with "Thirst"
    And I press "Save signal"
    Then I should see "Shows it by can't be blank"
    And I should see "Check for can't be blank"

  Scenario: Edit a signal
    Given "Linda Chen" has a signal "Thirst"
    And I am on the page for resident "Linda Chen"
    When I follow "Edit" for the signal "Thirst"
    And I fill in "Shows it by" with "Asks for juice"
    And I press "Save signal"
    Then I should see "Signal updated."
    And I should see "Asks for juice"

  Scenario: Remove a signal
    Given "Linda Chen" has a signal "Thirst"
    And "Linda Chen" has a signal "Pain"
    And I am on the page for resident "Linda Chen"
    When I press "Delete" for the signal "Thirst"
    Then I should see "Signal removed."
    And I should see "Pain"
    And I should not see "Thirst"
