Feature: Assign each recheck to another relative
  As a relative who just heard from staff
  So that someone actually checks the fix on the next visit
  I want to hand the recheck to a sibling and have it show up first on their home page

  Background:
    Given a resident "Linda Chen" exists
    And "David" is in the family of "Linda Chen"
    And "Amy" is in the family of "Linda Chen"
    And "Linda Chen" has a concern "Water cup out of reach" opened by "David"

  Scenario: Recording a staff response assigns the recheck
    Given I am signed in as "David"
    And I am on the concern page for "Water cup out of reach"
    When I fill in "Staff member" with "Maria R."
    And I fill in "What they said" with "We moved the bed table"
    And I select "Amy" from "Who should recheck"
    And I press "Save staff response"
    Then I should see "Amy is assigned to recheck it."
    And I should see "Recheck assigned to Amy"

  Scenario: The relative who opened the concern is not offered as the rechecker
    Given I am signed in as "David"
    When I go to the concern page for "Water cup out of reach"
    Then "David" should not be an option for "Who should recheck"

  Scenario: The assigned relative sees the recheck first on her home page
    Given staff reported "Water cup out of reach" as fixed and assigned the recheck to "Amy"
    And I am signed in as "Amy"
    When I go to the home page
    Then I should see "Water cup out of reach" in my rechecks
    When I start the recheck for "Water cup out of reach"
    Then I should see the recheck form

  Scenario: Other relatives do not get someone else's recheck
    Given "Grace" is in the family of "Linda Chen"
    And staff reported "Water cup out of reach" as fixed and assigned the recheck to "Amy"
    And I am signed in as "Grace"
    When I go to the home page
    Then I should not see "Water cup out of reach" in my rechecks
    And "Water cup out of reach" should be listed as "Reported fixed"
    And I should see "Recheck: Amy"

  Scenario: The relative who opened the concern cannot record its recheck
    Given staff reported "Water cup out of reach" as fixed and assigned the recheck to "Amy"
    And I am signed in as "David"
    When I go to the concern page for "Water cup out of reach"
    Then I should not see the recheck form
    And I should see "You opened this concern, so another relative needs to recheck it."

  Scenario: A family of one is asked to invite someone
    Given a resident "Robert Lee" exists
    And "Robert Lee" has a concern "Hearing aid not put in" opened by "Grace"
    And I am signed in as "Grace"
    When I go to the concern page for "Hearing aid not put in"
    Then I should see "Grace is the only one in this family"
    And I should see "Invite another relative"

  Scenario: The assigned relative hands the recheck to someone else
    Given "Grace" is in the family of "Linda Chen"
    And staff reported "Water cup out of reach" as fixed and assigned the recheck to "Amy"
    And I am signed in as "Amy"
    And I am on the concern page for "Water cup out of reach"
    When I select "Grace" from "Reassign the recheck to"
    And I press "Reassign recheck"
    Then I should see "Recheck reassigned to Grace."
    And I should see "Recheck assigned to Grace"
    When I go to the home page
    Then I should not see "Water cup out of reach" in my rechecks
    When I press "Sign out"
    And I am signed in as "Grace"
    Then I should see "Water cup out of reach" in my rechecks

  Scenario: A recheck can be opened up to anyone in the family
    Given staff reported "Water cup out of reach" as fixed and assigned the recheck to "Amy"
    And I am signed in as "Amy"
    And I am on the concern page for "Water cup out of reach"
    When I select "Anyone in the family" from "Reassign the recheck to"
    And I press "Reassign recheck"
    Then I should see "Recheck is no longer assigned. Anyone except David can check it."
    And I should see "Not assigned. Anyone except David can check it."

  Scenario: There is nothing to reassign before staff report a fix
    Given I am signed in as "Amy"
    When I go to the concern page for "Water cup out of reach"
    Then I should not see a "Reassign recheck" button
