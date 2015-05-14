Feature: Starting the game
  In order to play battleships
  As a nostalgic player
  I want to start a new game

  Scenario: Navigating to registration page
    Given I am on the homepage
    When I follow "New Game"
    Then I should see "What's your name?"

  Scenario: Entering name and going to ship placement
    Given I am on the Registration page
    When I fill in "name" with "Daniel"
    When I press "Let's go!"
    Then I should be on the Place Ships page
    Then I should see "Place your ships"

  Scenario: Place ships and see them on the grid
