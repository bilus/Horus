require "timeout"
require File.join(File.dirname(__FILE__), "be_json")

# class ForAtMostRunner
#   def initialize(secs)
#     @secs = secs
#   end
#   
#   def second
#     seconds
#   end
#   
#   def seconds(&block)
#     RSpec::Matchers.define :for_at_most do |actual|
#       match do |actual|
#         begin
#           timeout(@secs) { actual.call }
#           puts "true"
#           true
#         rescue Timeout::Error
#           puts "false"
#           false
#         end
#       end
#       failure_message_for_should do |actual|
#         "expected to run for at most #{@secs}s"
#       end
#     end
#   end
# end
# 
# def for_at_most(secs = 0.01)
#   ForAtMostRunner.new(secs)
# end


def for_at_most(secs, &block)
  
  # RSpec::Matchers.define :for_at_most_matcher do |expected|
  #   match do |actual|
  #     p expected
  #     p block
  #     # begin
  #     #   timeout(@secs) { actual.call }
  #     #   puts "true"
  #     #   true
  #     # rescue Timeout::Error
  #     #   puts "false"
  #     #   false
  #     # end
  #   end
  #   failure_message_for_should do |actual|
  #     "expected to run for at most #{secs}s"
  #   end
  # end
  # should for_at_most_matcher(secs, &block)
end

# 
# class ForAtLeastRunner
# 
#   def initialize(secs)
#     @secs = secs
#   end
#
#   def second
#     seconds
#   end
# 
#   def seconds
#     simple_matcher("to run for at least #{@secs}s") do |actual|
#       begin
#         timeout(@secs) { actual.call }
#         false
#       rescue Timeout::Error
#         true
#       end
#     end
#   end
# end
# 
# def for_at_least(secs = 0.01)
#   ForAtLeastRunner.new(secs)
# end