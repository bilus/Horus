Feature: Story composition game
  In order create a nice short story
  As a player
  I want to add tiles with other players in turns until game ends 

	@acceptance @story1
	Scenario: Story #1 - one player starts game, adds one tile
		Given one player
		When the player starts a new game
		And the player adds tile "Lorem"
		Then the board should display "Lorem"

	@acceptance @story2 
	Scenario: Story #2 - one player starts game, adds four tiles
		Given one player
		When the player starts a new game
		And the player adds tile "Lorem"
		And the player adds tile "ipsum"
		And the player adds tile "sit"
		And the player adds tile "amet"
		Then the board should display "Lorem ipsum sit amet"
		
	@acceptance @story3
	Scenario: Story #3 - after playing a game, a player can start a new game
		Given one player
		When the player starts a new game
		And the player adds tile "Lorem"
		And the player adds tile "ipsum"
		And the player starts a new game
		And the player adds tile "Hello"
		And the player adds tile "world"
		Then the board should display "Hello world"
		And the board should not display "Lorem ipsum"
		
	@acceptance @story4
	Scenario: Story #4 - two players can simultaneously play two separate games
		Given player "Joe"
		And player "Tim"
		When Joe starts a new game
		And Tim starts a new game
		And Joe adds tile "Lorem"
		And Joe adds tile "ipsum"
		And Tim adds tile "Hello"
		And Tim adds tile "world"
		Then Joe's board should display "Lorem ipsum"
		And Tim's board should display "Hello world"
		
	@acceptance @story5
	Scenario: Story #5 - players can join games in progress
		Given player "Joe"
		And player "Tim"
		When Joe starts a new game
		And Joe adds tile "Lorem"
		And Tim joins Joe's game
		And Tim adds tile "ipsum"
		And Joe adds tile "sit"
		Then Joe's board should display "Lorem ipsum sit"
		And Tim's board should display "Lorem ipsum sit"
		
	@acceptance @story6
	Scenario: Story #6 - when starting a game, player enters a nickname visible to other players
		Given player "Joe"
		And player "Tim"
		When Joe starts a new game
		And Tim joins Joe's game
		Then Tim sees Joe on player list
	# 	
	# Scenario: Player is not able to start game without a nickname
	# 	Given player "Joe"
	# 	When Joe tries to start a new game but doesn't enter the nickname
	# 	Then Joe cannot start the game

	@acceptance @story7
	Scenario: Story #7 - when joining a game, the player enters a nickname visible to other players
		Given player "Joe"
		And player "Tim"
		When Joe starts a new game
		And Tim joins Joe's game
		Then Joe sees Tim on player list
		
	# TODO After game ends adding new tiles is impossible.
	# TODO Adding a blank tile has no effect and doesn't end the player's turn.
	# TODO Add a test to verify that the text box is cleared after adding the word.
	

  
