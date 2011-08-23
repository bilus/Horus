# require File.join(File.dirname(__FILE__), '..', '..', 'front_end/application')

require 'capybara'
require 'capybara/cucumber'
require 'rspec/expectations'
require 'rspec/matchers'
require "selenium-webdriver"
require File.join(File.dirname(__FILE__), "thin_support")

# root = File.join(File.dirname(__FILE__), "..")
# 
# 
# config.before(:all) do
#   `bash #{root}/start`
# end
# 
# config.after(:all) do
#   `bash #{root}/stop`
# end

# require 'ruby-debug19'

Before do
    # breakpoint; 0
end

World do
  # Capybara.app = FrontEnd::Application
  Capybara.app_host = "http://localhost:3000"
  Capybara.default_driver = :selenium

  include Capybara::DSL
  include RSpec::Expectations
  include RSpec::Matchers
end

# Start/stop thin for remote tests on localhost.

print "Starting thin..."
start_thin
puts "OK"

at_exit do
  print "Stopping thin..."
  stop_thin
  puts "OK"
end