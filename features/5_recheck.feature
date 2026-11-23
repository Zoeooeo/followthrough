Feature: Check a reported fix while logging a visit
  As a relative visiting after my sibling
  So that the family knows whether a problem was really fixed
  I want to check the fix against the Signal Card and record what I saw as part of logging my visit

  Background:
    Given I am signed in as "Amy"
    And a resident "Linda Chen" exists
    And I am in the family of "Linda Chen"
    And "Linda Chen" has a signal "Thirst"
    And "Linda Chen" has a concern "Water cup out of reach" about "Thirst" opened by "David"
    And staff reported "Water cup out of reach" as fixed

  Scenario: The visit form shows what to look for from the Signal Card
    When I go to the new visit page for "Linda Chen"
    Then I should see "Water cup out of reach" in the visit checks
    And I should see "Cup within reach" in the recheck checklist
    And I should see "Cup half full" in the recheck checklist

  Scenario: The concern page sends the visitor to the visit log
    Given I am on the concern page for "Water cup out of reach"
    Then I should be asked to check it on a visit
    And I should see "Cup within reach" in the recheck checklist
    When I follow "Log a visit"
    Then I should see "Water cup out of reach" in the visit checks

  Scenario: A different relative verifies the fix during a visit
    Given I am on the new visit page for "Linda Chen"
    When I choose "Okay"
    And I mark "Water cup out of reach" as "Fixed"
    And I add the note "Cup on the right side, half full" for "Water cup out of reach"
    And I press "Save visit"
    Then I should see "Visit saved with 1 recheck."
    And I should see "Fixes checked on this visit"
    When I follow "Water cup out of reach"
    Then the status should be "Verified"
    And the progress should be at "Verified"
    And I should see "Family saw · Amy"
    And I should see "Cup on the right side, half full"
    And I should see "during the visit on"

  Scenario: The fix did not hold
    Given I am on the new visit page for "Linda Chen"
    When I choose "Okay"
    And I mark "Water cup out of reach" as "Still not fixed"
    And I press "Save visit"
    And I go to the concern page for "Water cup out of reach"
    Then the status should be "Not verified"
    And the progress should be at "Waiting for staff"
    And I should see the staff response form

  Scenario: A visitor who didn't get to a fix leaves it waiting
    Given I am on the new visit page for "Linda Chen"
    When I choose "Good"
    And I press "Save visit"
    Then I should see "Visit saved."
    When I go to the concern page for "Water cup out of reach"
    Then the status should be "Reported fixed"

  Scenario: The problem comes back after it was verified
    Given "Grace" verified "Water cup out of reach"
    And I am on the new visit page for "Linda Chen"
    When I choose "Not good"
    And I mark "Water cup out of reach" as "It came back"
    And I press "Save visit"
    And I go to the concern page for "Water cup out of reach"
    Then the status should be "Recurred"
    And I should see the staff response form

  Scenario: A verified concern leaves the open list
    Given "Grace" verified "Water cup out of reach"
    When I go to the page for resident "Linda Chen"
    Then I should see "No open concerns."
    And I should see "No rechecks due right now."
