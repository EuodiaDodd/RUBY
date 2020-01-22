Feature: Admin side of the website

Scenario: Invalid order information
    Given I have logged in as an admin
    When I press "New Order"
    When I fill in "Origin" with ""
    When I fill in "Destination" with ""
    When I fill in "Car" with ""
    When I fill in "Twitter Handle" with ""
    When I fill in "City" with ""
    When I press "Create Order"
    Then I should see "Please enter origin." within "body"
    And I should see "Please enter destination." within "body"
    And I should see "Please enter car." within "body"
    And I should see "Please enter user's twitter handle." within "body"
    And I should see "Please enter city." within "body"
    
Scenario: Creating admin account
    Given I have logged in as an admin
    When I follow "Create Admin" within "nav"
    When I fill in "name" with ""
    When I fill in "username" with ""
    When I fill in "password1" with ""
    When I fill in "passwordRepeat" with ""
    When I press "Create"
    Then I should see "Please enter name." within "body"
    And I should see "Invalid twitter handle." within "body"
    And I should see "Please enter password." within "body"
    And I should see "Passwords do not match." within "body"
    
Scenario: Creating a new order
    Given I have logged in as an admin
    When I press "New Order"
    When I fill in "origin" with "The Diamond"
    When I fill in "destination" with "Train Station"
    When I fill in "car" with "MINI Cooper"
    When I fill in "twitterhandle" with "@example"
    When I fill in "city" with "Sheffield"
    When I press "Create Order"
    Then I should be on the orders page
       
Scenario: Adding a new car
    Given I have logged in as an admin
    When I follow "Cars" within "nav"
    When I follow "New Car"
    When I fill in "Car Model" with "Toyota"
    When I fill in "Number of seats" with "4"
    When I fill in "Car registration" with "LA51ABC"
    When I fill in "Colour" with "Red"
    When I press "Enter New Car"
    Then I should be on the create new car page
    
Scenario: Adding invalid offer
    Given I have logged in as an admin
    When I follow "Offers" within "nav"
    When I fill in "userCode" with "8"
    When I press "Accept"
    Then I should see "Please input valid code"
    
Scenario: Filtering history
    Given I have logged in as an admin
    When I follow "History" within "nav"
    When I fill in "city" with "Manchester"
    When I press "Search"
    Then I should not see "Sheffield" within "tbody"

Scenario: History showing completed orders only
    Given I have logged in as an admin
    When I follow "History" within "nav"
    Then I should not see "Ongoing" within "tbody"

    