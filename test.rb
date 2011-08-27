require 'rack'
require 'em-http-request'
require File.join(File.dirname(__FILE__), "application")

class HelloWorld
  def call(env)
    [200, {"Content-Type" => "text/plain"}, ["Hello world!"]]
  end
end
# 
# @server_thread = Thread.new do
#   begin
#     # Dir.chdir(File.join(File.dirname(__FILE__), "../../"))
#     options = {:server => 'thin', :Port => 3000, :config => 'config.ru'}
#     # options = {:server => 'thin', :Port => 3000, :app => HelloWorld.new}#:config => 'config.ru'}
#     Rack::Server.start(options)
#   rescue => e
#     puts "Error in server thread: #{e}\n#{e.backtrace.join("\n")}"
#     throw
#   end
# end
# @server_thread.run
# # TODO Ugly: simply sleep for some time.
# sleep(2)
# 
# $stdout.sync = true
# 
# EM.run do
#   http = EventMachine::HttpRequest.new("http://localhost:3000/game_events?").get
#         http.errback { p 'Uh oh'; EM.stop }
#         http.callback {
#           p http.response_header.status
#           p http.response_header
#           p http.response
# 
#           EventMachine.stop
#         }
# end
# 
# sleep(5)

# require 'rack/test'
# 
# callback = proc { |response|
#   puts "callback called with #{response.inspect}"
#   response[-1].each { |chunk|
#     puts chunk
#   }
# }
# headers = {'async.callback' => callback, 'SCRIPT_NAME' => ''}
# 
# 
# action = CrampApp::Application.routes
# EM.run do
#   catch(:async) { action.call(headers) }
# end



require 'pp'

@request = Rack::MockRequest.new(CrampApp::Application.routes)
# @request = Rack::MockRequest.new(HelloWorld.new)

def get(path, options = {}, headers = {}, &block)
  callback = options.delete(:callback) || block
  headers = headers.merge('async.callback' => callback)

  EM.run do
    catch(:async) { 
      result = @request.get(path, headers) 
      # We're here because the app is not async or this is a response from
      # HttpRouter which is sync.
      callback.call([result.status, result.header, result.body])
    }
  end
end

# TODO get function should pull the body and return the result. 
# TODO get function should optionally timeout after some time (options = {:timeout => 5}).
# TODO get function should handle sync results.

# TODO post method
# TODO post method works with params

# TODO get_chunks method for SSE
# TODO get_chunks method yields for every chunk.
# TODO get_chunks - optional timeout
# TODO get_chunks - properly report routing errors.
# TODO get_chunks - way to specify maxmimum chunks.
  
def post(path, options = {}, headers = {}, &block)
  callback = options.delete(:callback) || block
  headers = headers.merge('async.callback' => callback)

  EM.run do
    catch(:async) do 
      result = @request.post(path, headers) 
      callback.call([result.status, result.header, result.body])
    end
  end
end


post('/add_tile', {}, :params => {:tile => "Lorem"}) do |response|
  # pp response
  # EM.stop
  if response[0] == 200
    response[-1].each do |chunk|
      puts chunk
      EM.stop
    end
  else
    puts "Oops! #{response[0]}"
    EM.stop
  end
  # if response[0] == 500
  #   puts "oops!"
  #   EM.stop
  # else
  #   pp response
  #   EM.stop
  # end
  
  # puts "callback called with #{response.inspect}"
  # response[-1].each { |chunk|
  #   puts chunk
  #   EM.stop
  #   # raise "some error"
  # }
end