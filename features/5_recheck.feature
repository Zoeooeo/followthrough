Feature: Recheck a reported fix on the next visit
  As a relative visiting after my sibling
  So that the family knows whether a problem was really fixed
  I want to check the concern against the Signal Card and record what I saw

  Background:
    Given I am signed in as "Amy"
    And a resident "Linda Chen" exists
    And I am in the family of "Linda Chen"
    And "Linda Chen" has a signal "Thirst"
    And "Linda Chen" has a concern "Water cup out of reach" about "Thirst" opened by "David"
    And staff reported "Water cup out of reach" as fixed

  Scenario: The recheck shows what to look for from the Signal Card
    When I go to the concern page for "Water cup out of reach"
    Then I should see "Cup within reach" in the recheck checklist
    And I should see "Cup half full" in the recheck checklist

  Scenario: A different relative verifies the fix
    Given I am on the concern page for "Water cup out of reach"
    When I choose "Verified"
    And I fill in "Note" with "Cup on the right side, half full"
    And I press "Save recheck"
    Then I should see "Recheck saved: Verified."
    And the status should be "Verified"
    And the progress should be at "Verified"
    And I should see "Family saw · Amy"
    And I should see "Cup on the right side, half full"

  Scenario: The fix did not hold
    Given I am on the concern page for "Water cup out of reach"
    When I choose "Not verified"
    And I fill in "Note" with "Cup on the windowsill, empty"
    And I press "Save recheck"
    Then the status should be "Not verified"
    And the progress should be at "Waiting for staff"
    And I should see the staff response form

  Scenario: A recheck needs a result
    Given I am on the concern page for "Water cup out of reach"
    When I press "Save recheck"
    Then I should see "Result must be Verified, Not verified, or Recurred"

  Scenario: The problem comes back after it was verified
    Given "Grace" verified "Water cup out of reach"
    And I am on the concern page for "Water cup out of reach"
    When I choose "Recurred"
    And I press "Save recheck"
    Then the status should be "Recurred"
    And I should see the staff response form

  Scenario: A verified concern leaves the open list
    Given "Grace" verified "Water cup out of reach"
    When I go to the page for resident "Linda Chen"
    Then I should see "No open concerns."
    And I should see "No rechecks due right now."
