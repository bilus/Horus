require 'capybara'
require 'capybara/cucumber'
require 'rspec/expectations'
require 'rspec/matchers'
require "selenium-webdriver"
require File.join(File.dirname(__FILE__), "thin_support")

World do
  Capybara.app_host = "http://localhost:3000"
  Capybara.default_driver = :selenium
  Capybara.default_wait_time = 3
  # I turned off resynchronization because there's always
  # at least one outstanding connection (EventSource).
  Capybara::Selenium::Driver::DEFAULT_OPTIONS[:resynchronize] = false

  include Capybara::DSL
  include RSpec::Expectations
  include RSpec::Matchers
end

# Start/stop thin for remote tests on localhost.

print "Starting thin..."
start_thin
puts "OK"

trap("INT") do
  exit
end

at_exit do
  print "Stopping thin..."
  stop_thin
  puts "OK"
end