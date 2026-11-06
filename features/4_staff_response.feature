Feature: Record what staff said
  As a family member
  So that a staff promise is kept on record and is not mistaken for a real fix
  I want to record what staff said and see the concern marked "Reported fixed", not resolved

  Background:
    Given a resident "Linda Chen" exists
    And "Linda Chen" has a concern "Water cup out of reach" opened by "David"

  Scenario: Staff say the problem is fixed
    Given I am on the concern page for "Water cup out of reach"
    When I fill in "Staff member" with "Maria R."
    And I fill in "What they said" with "We moved the bed table to her right side"
    And I fill in "Date" with "2026-10-14"
    And I press "Save staff response"
    Then the status should be "Reported fixed"
    And I should see "Staff said"
    And I should see "We moved the bed table to her right side"
    And I should see the recheck form

  Scenario: A reported fix shows up as a recheck due
    Given staff reported "Water cup out of reach" as fixed
    When I go to the page for resident "Linda Chen"
    Then I should see "Water cup out of reach" in the rechecks due
    And "Water cup out of reach" should be listed as "Reported fixed"

  Scenario: Staff member is required
    Given I am on the concern page for "Water cup out of reach"
    When I fill in "What they said" with "We will look into it"
    And I press "Save staff response"
    Then I should see "Staff member can't be blank"
    And the status should be "Open"

  Scenario: No second staff response while waiting for a recheck
    Given staff reported "Water cup out of reach" as fixed
    When I go to the concern page for "Water cup out of reach"
    Then I should not see the staff response form
