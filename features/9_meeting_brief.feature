Feature: Bring a one-page brief to the care plan meeting
  As a relative going to a care plan meeting
  So that the meeting starts from a shared record instead of memory
  I want a summary of what staff reported fixed and what the family actually saw

  Background:
    Given I am signed in as "Amy"
    And a resident "Linda Chen" exists
    And I am in the family of "Linda Chen"
    And "Linda Chen" has a concern "Water cup out of reach" opened by "David"
    And "Linda Chen" has a concern "Glasses not cleaned" opened by "David"
    And "Linda Chen" has a concern "Call button out of reach" opened by "David"
    And staff reported "Water cup out of reach" as fixed on "2026-11-02"
    And staff reported "Glasses not cleaned" as fixed on "2026-11-03"
    And staff reported "Call button out of reach" as fixed on "2026-09-01"
    And "Amy" verified "Glasses not cleaned" on "2026-11-05"
    And "Amy" marked "Water cup out of reach" as not verified on "2026-11-06"

  Scenario: Compare what staff reported with what the family saw
    Given I am on the meeting brief for "Linda Chen"
    When I fill in "From" with "2026-11-01"
    And I fill in "To" with "2026-11-30"
    And I press "Update"
    Then I should see "Period: November 1, 2026 to November 30, 2026"
    And the brief should show 2 reported fixed, 1 verified, and 1 not seen fixed
    And I should see "1 not verified"
    And I should not see "Call button out of reach"

  Scenario: Each row puts staff and family side by side
    Given I am on the meeting brief for "Linda Chen"
    When I fill in "From" with "2026-11-01"
    And I fill in "To" with "2026-11-30"
    And I press "Update"
    Then the brief row for "Water cup out of reach" should show "We moved the bed table"
    And the brief row for "Water cup out of reach" should show "Amy: Not verified"
    And the brief row for "Glasses not cleaned" should show "Verified"

  Scenario: A period with nothing to report
    Given I am on the meeting brief for "Linda Chen"
    When I fill in "From" with "2025-01-01"
    And I fill in "To" with "2025-01-31"
    And I press "Update"
    Then the brief should show 0 reported fixed, 0 verified, and 0 not seen fixed
    And I should see "No staff responses or rechecks in this period."

  Scenario: The brief is ready to print
    When I go to the meeting brief for "Linda Chen"
    Then I should see "Print or save as PDF"
    And I should see "Family observations, not medical judgment."
