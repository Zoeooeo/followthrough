Feature: Share a private family space
  As the relative who set up my mother's profile
  So that my siblings can follow up on her care with me
  I want to invite them with a code, while keeping everyone else out

  Background:
    Given a resident "Linda Chen" exists
    And "David" is the organizer for "Linda Chen"

  Scenario: The organizer sees the invite code
    Given I am signed in as "David"
    When I go to the family page for "Linda Chen"
    Then I should see the invite code for "Linda Chen"
    And "David" should be listed as "Organizer" in the family
    And I should see "Private to family only."

  Scenario: A relative joins with the invite code
    Given I am signed in as "Amy"
    And I am on the home page
    When I follow "Join with an invite code"
    And I fill in the invite code for "Linda Chen"
    And I press "Join family"
    Then I should see "You joined Linda Chen's family."
    When I go to the family page for "Linda Chen"
    Then "Amy" should be listed as "Relative" in the family

  Scenario: A wrong invite code
    Given I am signed in as "Amy"
    And I am on the join page
    When I fill in "Invite code" with "WRONG123"
    And I press "Join family"
    Then I should see "That invite code doesn't match any family."

  Scenario: Joining a family twice
    Given "Amy" is in the family of "Linda Chen"
    And I am signed in as "Amy"
    And I am on the join page
    When I fill in the invite code for "Linda Chen"
    And I press "Join family"
    Then I should see "You're already in Linda Chen's family."

  Scenario: Someone outside the family cannot see the profile
    Given I am signed in as "Grace"
    When I go to the page for resident "Linda Chen"
    Then I should see "We couldn't find that page."
    And I should not see "Signal Card"

  Scenario: The organizer removes a relative
    Given "Amy" is in the family of "Linda Chen"
    And I am signed in as "David"
    And I am on the family page for "Linda Chen"
    When I press "Remove" for the member "Amy"
    Then I should see "Amy was removed from the family."

  Scenario: Relatives cannot remove anyone
    Given "Amy" is in the family of "Linda Chen"
    And I am signed in as "Amy"
    When I go to the family page for "Linda Chen"
    Then I should not see a "Remove" button
