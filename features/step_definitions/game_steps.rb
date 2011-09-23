Given /^one player$/ do
end

Given /^player "([^"]*)"$/ do |arg1|
end

Given /^visitor "([^"]*)"$/ do |visitor|
end

When /^the player starts a new game$/ do
  visit("/")
  start_game
  enter_nickname
  open_game
end

When /^(.*) joins (.*)'s game$/ do |player, game_owner| 
  Capybara.session_name = player
  visit "/"
  join_game(game_owner)
  enter_nickname
  open_game
end

When /^the player adds tile "([^"]*)"$/ do |s|
  add_tile(s)
end

When /^(?!the player)(.*) starts a new game$/ do |player|
  Capybara.session_name = player
  When "the player starts a new game"
end

When /^(.*) tries to start a new game but doesn't enter the nickname$/ do |player|
  Capybara.session_name = player
  visit("/")
  start_game
  confirm_start_game
end

When /^(?!the player)(.*) adds tile "([^"]*)"$/ do |player, tile|
  Capybara.session_name = player
  When "the player adds tile \"#{tile}\""
end

When /^(?!the player)(.*) tries to add tile "([^"]*)"$/ do |player, tile|
  Capybara.session_name = player
  When "the player tries to add tile \"#{tile}\""
end

When /^the player tries to add tile "([^"]*)"$/ do |s|
  add_tile(s)
end

When /^(.*) starts watching (.*)'s game$/ do |visitor, game_owner|
  Capybara.session_name = visitor
  watch_game(game_owner)
end

Then /^(.*) should not be able to interact with the game$/ do |visitor|
  Capybara.session_name = visitor
  page.should_not have_css("#game input#tile", :visible => true)
  page.should_not have_css("#game #add", :visible => true)
end

Then /^the board should display "([^"]*)"$/ do |s|
  # We need to wait here because I turned off resynchronization because there's always
  # at least one outstanding connection (EventSource).
  # See environment.rb (:resynchronize option).
  wait_until { board_displays?(s) }
  board_should_display(s)
end

Then /^the board should not display "([^"]*)"$/ do |s|
  board_should_not_display(s)
end

Then /^(.*)'s board should display "([^"]*)"$/ do |player, s|
  Capybara.session_name = player
  Then "the board should display \"#{s}\""
end

Then /^(.*)'s board should not display "([^"]*)"$/ do |player, s|
  Capybara.session_name = player
  Then "the board should not display \"#{s}\""
end

Then /^(.*)'s board should contain "([^"]*)"$/ do |player, s|
  Capybara.session_name = player
  Then "the board should contain \"#{s}\""
end

Then /^the board should contain "([^"]*)"$/ do |s|
  wait_until { board_contains?(s) }
  board_should_contain(s)
end

Then /^the board should not contain "([^"]*)"$/ do |s|
  board_should_not_contain(s)
end

Then /^(.*) sees (.*) on player list$/ do |player, other_player|
  find("#players").should have_content(other_player)
end

Then /^(.*) cannot add tiles$/ do |player|
  page.should_not have_css("input#tile")
end

Then /^(.*) should be unable to add tile "([^"]*)"$/ do |player, tile|
  When "#{player} adds tile \"#{tile}\""
  sleep(1)
  Then "the board should not contain \"#{tile}\""
end

Then /^(.*) should be able to add tile "([^"]*)"$/ do |player, tile|
  When "#{player} adds tile \"#{tile}\""
  Then "the board should contain \"#{tile}\""
end

Then /^game should respond with an error "([^"]*)"$/ do |status|
  find("#error").should have_content(status)
end

Then /^(.*) should see that it's (.*)'s turn$/ do |watcher, player|
  Capybara.session_name = player
  page.should have_xpath("//div[@id = 'players']/*[contains(text(), '#{player}') and contains(@class, 'current')]")
end