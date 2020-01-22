Feature: User navigation through the website

Scenario: Clicking history button to view user history 
    Given I have logged in as a user
    When I press "History"
    Then I should be on the user history page
    
Scenario: User viewing their history 
    Given I have logged in as a user
    When I press "History"
    Then I should see "@example" within "tbody"
    And I should not see "@example_handle" within "tbody"

Scenario: Clicking button to view cars
    Given I have logged in as a user
    When I press "Car Information"
    Then I should be on the cars page

Scenario: Clicking cars button to view cars
    Given I have logged in as a user
    When I press "Offers Information"
    Then I should be on the offers page
    
    
Scenario: Home button on nav bar
    Given I have logged in as a user
    When I follow "Home" within "nav"
    Then I should be on the user homepage
    
Scenario: Invalid code
    Given I have logged in as a user 
    When I follow "Offers" within "nav"
    When I fill in "code" with "1234"
    When I press "Redeem"
    Then I should see "Code does not exist or is already redeemed, please enter another code" within "p"
    
    
Scenario: Clicking history button to view user history 
    Given I have logged in as a user
    When I press "History"
    Then I should be on the user history page
    
Scenario: User viewing their history 
    Given I have logged in as a user
    When I press "History"
    Then I should see "@example" within "tbody"
    And I should not see "@example_handle" within "tbody"

Scenario: Clicking button to view cars
    Given I have logged in as a user
    When I press "Car Information"
    Then I should be on the cars page

Scenario: Clicking cars button to view cars
    Given I have logged in as a user
    When I press "Offers Information"
    Then I should be on the offers page
    
Scenario: Home button on nav bar
    Given I have logged in as a user
    When I follow "Home" within "nav"
    Then I should be on the user homepage
    
    
Scenario: Creating a new account 
    Given I am on the create new account page
    When I fill in "name" with "Jane Doe"
    When I fill in "handle" with "@twitterhandle"
    When I fill in "password1" with "password123"
    When I fill in "password2" with "password123"
    When I press "Create"
    Then I should be on the new account page
    
Scenario: Inputting two passwords that dont match
    Given I am on the create new account page
    When I fill in "name" with "Jane Doe"
    When I fill in "handle" with "@twitterhandle"
    When I fill in "password1" with "password123"
    When I fill in "password2" with "password"
    When I press "Create"
    Then I should see "Passwords do not match, please try again." within "body"
    
Scenario: Filtering history
    Given I have logged in as a user
    When I follow "History" within "nav"
    When I fill in "city" with "Manchester"
    When I press "Search"
    Then I should not see "Sheffield" within "tbody"
    
    
Scenario: Should only see my history
    Given I have logged in as a user
    When I follow "History" within "nav"
    Then I should not see "@test" within "tbody"