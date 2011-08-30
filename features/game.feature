Feature: Story composition game
  In order create a nice short story
  As a player
  I want to add tiles with other players in turns until game ends 

	@acceptance @story1
	Scenario: Story #1 - one player starts game, adds one tile
		Given a new game
		And one player
		When the player adds tile "Lorem"
		Then the board should display "Lorem"

	@acceptance @story2 
	Scenario: Story #2 - one player starts game, adds four tiles
		Given a new game
		And one player
		When the player adds tile "Lorem"
		And the player adds tile "ipsum"
		And the player adds tile "sit"
		And the player adds tile "amet"
		Then the board should display "Lorem ipsum sit amet"

	# TODO After game ends adding new tiles is impossible.
	# TODO Adding a blank tile has no effect and doesn't end the player's turn.
	# TODO Add a test to verify that the text box is cleared after adding the word.
	

  
