Feature: login

Scenario: Correct password entered for user
    Given I am on the user login page
    When I fill in "handle" with "@example"
    When I fill in "password" with "password"
    When I press "Submit"
    Then I should be on the user account page
    
Scenario: Incorrect information entered 
    Given I am on the user login page
    When I fill in "password" with ""
    When I fill in "handle" with ""
    When I press "Submit"
    Then I should see "Incorrect username/password, please try again." within "p"
        
Scenario: Correct password entered for admin
    Given I am on the admin login page
    When I fill in "username" with "username"
    When I fill in "password" with "password"
    When I press "Submit"
    Then I should be on the admin homepage 

Scenario: Incorrect information entered for admin
    Given I am on the admin login page
    When I fill in "password" with ""
    When I fill in "username" with ""
    When I press "Submit"
    Then I should see "Incorrect username/password, please try again." within "p"

Scenario: Logging out
    Given I have logged in as a user
    When I press "Logout"
    Then I should be on the splash page
    
Scenario: Logging out
    Given I have logged in as an admin
    When I press "Logout"
    Then I should be on the splash page
