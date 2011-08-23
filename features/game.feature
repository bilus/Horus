Feature: Story composition game
  In order create a nice short story
  As a player
  I want to add tiles with other players in turns until game ends 

	@acceptance_test
	Scenario: Story #1 - one player starts game, adds one tile and game ends
		Given a new game
		And one player
		When the player adds tile "Lorem"
		Then the board should display "Lorem"

	# TODO After game ends adding new tiles is impossible
	

  
