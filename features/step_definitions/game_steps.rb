Given /^one player$/ do
end

Given /^player "([^"]*)"$/ do |arg1|
end

When /^the player starts a new game$/ do
  visit("/")
  start_game
  enter_nickname
  confirm_start_game
end

When /^(.*) joins (.*)'s game$/ do |player, game_owner| 
  Capybara.session_name = player
  visit "/"
  join_game(game_owner)
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

Then /^the board should display "([^"]*)"$/ do |s|
  # We need to wait here because I turned off resynchronization because there's always
  # at least one outstanding connection (EventSource).
  # See environment.rb (:resynchronize option).
  wait_until { find("#board").text == s }
  find("#board").text.should == s
end

Then /^the board should not display "([^"]*)"$/ do |s|
  find("#board").should_not have_content(s)
end

Then /^(.*)'s board should display "([^"]*)"$/ do |player, s|
  Capybara.session_name = player
  Then "the board should display \"#{s}\""
end

Then /^(.*)'s board should not display "([^"]*)"$/ do |player, s|
  Capybara.session_name = player
  Then "the board should not display \"#{s}\""
end

Then /^(.*) sees (.*) on player list$/ do |player, other_player|
  find("#players").should have_content(other_player)
end

Then /^(.*) cannot add tiles$/ do |player|
  page.should_not have_css("input#tile")
end


