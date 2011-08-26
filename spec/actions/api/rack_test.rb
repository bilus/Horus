require "async_rack"
require "rack"
require File.join(File.dirname(__FILE__), "../../../application")

$stdout.sync = true


def start
  t = Thread.new do
    Dir.chdir(File.join(File.dirname(__FILE__), "../../../"))
    server = Rack::Server.new(:server => 'thin', :app => CrampApp::Application.routes, :Port => 3001)#:config => 'config.ru', :Port => 3001)
    server.start
  end
  t.run
end
# t.join



# require "em-synchrony"
# require "em-synchrony/em-http"
# 
# EM.synchrony do
#   start
#   
#   EM::Synchrony.sleep(2)
#   result = EM::Synchrony.sync EventMachine::HttpRequest.new('http://localhost:3001/add_tile').apost(:params => {:tile => "Lorem"})
#   # r = EventMachine::HttpRequest.new("http://localhost:3000").get
#   # puts result.response.body
#   p result.response
#   # p result
#   EM.stop
# end

# use em-eventmachine for server sent events (game_events)

require 'net/http'

start
sleep(2)
# result = Net::HTTP.post_form URI.parse("http://localhost:3001/add_tile"), {"tile" => "Lorem"}
result = Net::HTTP.get_response URI.parse("http://localhost:3001/")
p result.body

