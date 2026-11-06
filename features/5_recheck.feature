Feature: Recheck a reported fix on the next visit
  As a relative visiting after my sibling
  So that the family knows whether a problem was really fixed
  I want to check the concern against the Signal Card and record what I saw

  Background:
    Given a resident "Linda Chen" exists
    And "Linda Chen" has a signal "Thirst"
    And "Linda Chen" has a concern "Water cup out of reach" about "Thirst" opened by "David"
    And staff reported "Water cup out of reach" as fixed

  Scenario: The recheck shows what to look for from the Signal Card
    When I go to the concern page for "Water cup out of reach"
    Then I should see "Cup within reach" in the recheck checklist
    And I should see "Cup half full" in the recheck checklist

  Scenario: A different relative verifies the fix
    Given I am on the concern page for "Water cup out of reach"
    When I fill in "Checked by" with "Amy"
    And I choose "Verified"
    And I fill in "Note" with "Cup on the right side, half full"
    And I press "Save recheck"
    Then I should see "Recheck saved: Verified."
    And the status should be "Verified"
    And I should see "Family saw"
    And I should see "Cup on the right side, half full"

  Scenario: The fix did not hold
    Given I am on the concern page for "Water cup out of reach"
    When I fill in "Checked by" with "Amy"
    And I choose "Not verified"
    And I fill in "Note" with "Cup on the windowsill, empty"
    And I press "Save recheck"
    Then the status should be "Not verified"
    And I should see the staff response form

  Scenario: The relative who opened the concern cannot recheck it
    Given I am on the concern page for "Water cup out of reach"
    When I fill in "Checked by" with "David"
    And I choose "Verified"
    And I press "Save recheck"
    Then I should see "Checked by must be a different relative than David, who opened this concern"
    And the status should be "Reported fixed"

  Scenario: The problem comes back after it was verified
    Given "Amy" verified "Water cup out of reach"
    And I am on the concern page for "Water cup out of reach"
    When I fill in "Checked by" with "Grace"
    And I choose "Recurred"
    And I press "Save recheck"
    Then the status should be "Recurred"
    And I should see the staff response form

  Scenario: A verified concern leaves the open list
    Given "Amy" verified "Water cup out of reach"
    When I go to the page for resident "Linda Chen"
    Then I should see "No open concerns."
    And I should see "No rechecks due right now."
