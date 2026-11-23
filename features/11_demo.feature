Feature: Try a demo family before signing up
  As someone who just heard about FollowThrough
  So that I can decide whether it fits my family before making an account
  I want to explore a sample family of my own without signing up

  Scenario: A visitor explores the demo and checks a fix
    Given I am on the sign in page
    When I press "Try a demo family"
    Then I should see "You're exploring a demo family"
    And I should see "Water cup out of reach" in my rechecks
    When I start the recheck for "Water cup out of reach"
    And I choose "Okay"
    And I mark "Water cup out of reach" as "Fixed"
    And I press "Save visit"
    Then I should see "Visit saved with 1 recheck."

  Scenario: Leaving the demo deletes it and opens sign up
    Given I am on the sign in page
    When I press "Try a demo family"
    And I press "Leave the demo and sign up"
    Then I should see "The demo family was deleted. Create an account to start your own."
    And I should see "Create an account"
