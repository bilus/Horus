Given /^one player$/ do
end

Given /^player "([^"]*)"$/ do |arg1|
end

When /^the player starts a new game$/ do
  visit("/")
end

When /^the player adds tile "([^"]*)"$/ do |s|
  find("input#tile").set(s)
  find("#add").click
end

When /^(?!the player)(.*) starts a new game$/ do |player|
    Capybara.session_name = player
    When "the player starts a new game"
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


