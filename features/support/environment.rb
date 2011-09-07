require 'capybara'
require 'capybara/cucumber'
require 'capybara/rspec'
require 'rspec/expectations'
require 'rspec/matchers'
require "selenium-webdriver"
require "pp"
require "ruby-debug"
require File.join(File.dirname(__FILE__), "thin_support")
require File.join(File.dirname(__FILE__), "helpers")


# Monkey-patch cucumber formatter to avoid hanging on error/exception.
require 'cucumber/formatter/console'
module Cucumber
  module Formatter
    module Console
      def print_exception(e, status, indent)
        # Old:
        # message = "#{e.message} (#{e.class})"  #hangs in call to 'class'.
        # New:
        message = e.inspect
        if ENV['CUCUMBER_TRUNCATE_OUTPUT']
          message = linebreaks(message, ENV['CUCUMBER_TRUNCATE_OUTPUT'].to_i)
        end

        string = "#{message}\n#{e.backtrace.join("\n")}".indent(indent)
        @io.puts(format_string(string, status))
      end
    end
  end
end

World do
  Capybara.app_host = "http://localhost:3000"
  Capybara.default_driver = :selenium
  Capybara.default_wait_time = 3
  Capybara.run_server = false
  # I turned off resynchronization because there's always
  # at least one outstanding connection (EventSource).
  Capybara::Selenium::Driver::DEFAULT_OPTIONS[:resynchronize] = false

  include Capybara::DSL
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