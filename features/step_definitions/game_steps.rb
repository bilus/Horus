Given /^one player$/ do
end

When /^the player starts a new game$/ do
  visit("/")
end

When /^the player adds tile "([^"]*)"$/ do |s|
  find("input#tile").set(s)
  find("#add").click
end

Then /^the board should display "([^"]*)"$/ do |s|
  # We need to wait here because I turned off resynchronization because there's always
  # at least one outstanding connection (EventSource).
  # See environment.rb (:resynchronize option).
  wait_until { find("#board").has_content?(s) }
  find("#board").should have_content(s)
end

Then /^the board should not display "([^"]*)"$/ do |s|
  find("#board").should_not have_content(s)
end

