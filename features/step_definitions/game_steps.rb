Given /^one player$/ do
end

Given /^player "([^"]*)"$/ do |arg1|
end

When /^the player starts a new game$/ do
  visit("/")
  find("#new-game").click
  wait_until { find("#board") }
  @games ||= {}
  @games[Capybara.session_name] = current_url
end

When /^(.*) joins (.*)'s game$/ do |player, game_owner| 
  Capybara.session_name = player
  visit "/"
  url = File.basename(@games[game_owner])
  find(:xpath, "//a[contains(@href, '#{url}')]").click
end

When /^the player adds tile "([^"]*)"$/ do |s|
  find("input#tile").set(s)
  find("#add").click
end

When /^(?!the player)(.*) starts a new game$/ do |player|
  begin
    Capybara.session_name = player
    When "the player starts a new game"
  rescue => e
    puts e
  end
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
  # Capybara.session_name = player
  # Then "the board should not display \"#{s}\""
end


