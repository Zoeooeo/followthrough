Feature: Sign up and sign in
  As a relative
  So that only my family can see my mother's care records
  I want my own account and to sign in before seeing any real family's records

  Scenario: Sign up
    Given I am on the sign up page
    When I fill in "Name" with "Amy Chen"
    And I fill in "Email" with "amy.chen@example.com"
    And I fill in "Password" with "password123"
    And I fill in "Confirm password" with "password123"
    And I press "Create account"
    Then I should see "Welcome to FollowThrough, Amy Chen."
    And I should see "Signed in as Amy Chen"

  Scenario: An email can only be used once
    Given a user "Amy" exists
    And I am on the sign up page
    When I fill in "Name" with "Another Amy"
    And I fill in "Email" with "AMY@example.com"
    And I fill in "Password" with "password123"
    And I fill in "Confirm password" with "password123"
    And I press "Create account"
    Then I should see "Email has already been taken"

  Scenario: Passwords need at least 8 characters and must match
    Given I am on the sign up page
    When I fill in "Name" with "Amy"
    And I fill in "Email" with "amy@example.com"
    And I fill in "Password" with "short"
    And I fill in "Confirm password" with "different"
    And I press "Create account"
    Then I should see "Password is too short (minimum is 8 characters)"
    And I should see "Confirm password doesn't match Password"

  Scenario: Sign in with the wrong password
    Given a user "Amy" exists
    And I am on the sign in page
    When I fill in "Email" with "amy@example.com"
    And I fill in "Password" with "wrong-password"
    And I press "Sign in"
    Then I should see "Incorrect email or password."

  Scenario: Sign out
    Given I am signed in as "Amy"
    When I press "Sign out"
    Then I should see "You have signed out."
    And I should not see "Signed in as Amy"

  Scenario: Care records are private until you sign in
    Given a resident "Linda Chen" exists
    And "Amy" is in the family of "Linda Chen"
    When I go to the page for resident "Linda Chen"
    Then I should see "Please sign in to continue."
    When I fill in "Email" with "amy@example.com"
    And I fill in "Password" with "password123"
    And I press "Sign in"
    Then I should see "Signed in as Amy"
    And I should see "Signal Card"
