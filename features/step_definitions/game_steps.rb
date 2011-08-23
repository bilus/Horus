Given /^a new game$/ do
  visit("/")
end

Given /^one player$/ do
end

When /^the player adds tile "([^"]*)"$/ do |s|
  find("input#tile").set(s)
  find("#add").click
end

Then /^the board should display "([^"]*)"$/ do |arg1|
  find("#board").should have_content(s)
end

