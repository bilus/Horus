require File.join(File.dirname(__FILE__), "../spec_helper")

def context_for_cramp_app(&example_group_block)
  
  example_group_class = context("cramp app") do

    before(:all) do 
      @request = Rack::MockRequest.new(app)
    end
    
    def get(path, options = {}, headers = {}, &block)
      callback = options.delete(:callback) || block || read_one_body_chunk_and_stop
      headers = headers.merge('async.callback' => callback)

      EM.run do
        catch(:async) do
          result = @request.get(path, headers)
          callback.call([result.status, result.header, result.body])
        end
      end
    end

    def get_body(path, options = {}, headers = {}, &block)
      callback = options.delete(:callback) || block || read_one_body_chunk_and_stop
      response_callback = proc {|response| response[-1].each {|chunk| callback.call(chunk) } }
      headers = headers.merge('async.callback' => response_callback)

      EM.run do
        catch(:async) do 
          result = @request.get(path, headers) 
          callback.call([result.status, result.header, result.body])
        end
      end
    end

    def get_body_chunks(path, options = {}, headers = {}, &block)
      callback = options.delete(:callback) || block || read_one_body_chunk_and_stop
      count = options.delete(:count) || 1

      stopping = false
      chunks = []

      get_body(path, options, headers) do |body_chunk|
        chunks << body_chunk unless stopping

        if chunks.count >= count
          stopping = true
          callback.call(chunks) if callback
          EM.next_tick { EM.stop }
        end
      end
    end
    
    def post(path, options = {}, headers = {}, &block)
      callback = options.delete(:callback) || block || read_one_body_chunk_and_stop
      headers = headers.merge('async.callback' => callback)

      EM.run do
        catch(:async) do 
          result = @request.post(path, headers) 
          callback.call([result.status, result.header, result.body])
        end
      end
    end
    
    def stop
      EM.stop
    end
    
    private
    
    def read_one_body_chunk_and_stop
      proc do |response|
        response[-1].each do |chunk|
          stop
        end
      end
    end  
  end
  example_group_class.class_eval &example_group_block
end


##################
# Matchers

def action(path)
  path
end

RSpec::Matchers.define :respond_with_events do |expected_chunks|
  match do |path|
    @result = false
    get_body_chunks path, :count => expected_chunks.size do |actual_chunks|
      @expected_chunks = expected_chunks
      @actual_chunks = actual_chunks
      @result = expected_chunks.zip(actual_chunks).find do |expected, actual|
        # pp actual
        # pp expected
        # puts "#{(actual =~ /^data: (.*)$/).nil? || $1 != expected}"
        (actual =~ /^data: (.*)$/).nil? || $1 != expected
      end.nil? ? true : false
    end
    @result
  end
  failure_message_for_should do
    "expected #{@expected_chunks.inspect} in data but got the following response from server: #{@actual_chunks.inspect}"
  end
end





# require 'net/http'
# require 'active_support/core_ext/object/to_query'
# # require 'em-eventsource'
# 
# ##
# # Allows $stdout to be set via Thread.current[:stdout] per thread.
# module ThreadStdOut
# 
#   def self.write(stuff)
#     stream.write stuff
# 
#   end
# 
#   def self.<<(stuff)
#     stream << stuff
#   end
#   
#   def self.puts(stuff)
#     stream.puts(stuff)
#   end
#   
#   private
#   
#   def self.stream    
#     Thread.current[:stdout] || STDOUT
#   end
# 
# end
# 
# ##
# # Allows $stderr to be set via Thread.current[:stderr] per thread.
# module ThreadStdErr
#   
#   def self.write(stuff)
#     stream.write stuff
# 
#   end
# 
#   def self.<<(stuff)
#     stream << stuff
#   end
#   
#   def self.puts(stuff)
#     stream.puts(stuff)
#   end
#   
#   private
#   
#   def self.stream    
#     Thread.current[:stderr] || STDERR
#   end
# 
# end
# 
# ##
# # Monkey-patch rspec to allow to check example status in after(:each)
# class RSpec::Core::Example
#   attr_reader :exception
#   
#   def passed?
#     @exception.nil?
#   end
#   
#   def failed?
#     !passed?
#   end
# end
# 
# require 'rspec/core/formatters/base_text_formatter'
# 
# module RSpec::Core::Formatters
#   class BaseTextFormatter
#     alias_method :base_dump_failure, :dump_failure
#     def dump_failure(example, index)
#       base_dump_failure(example, index)
#       output.puts "__ START SERVER LOG DUMP --\n" 
#       output.puts example.execution_result[:cramp_log]
#       output.puts "-- END SERVER LOG DUMP --"
#       output.flush
#     end
#   end
# end
# 
# require 'rspec/core/formatters/html_formatter'
# 
# module RSpec::Core::Formatters
#   class HtmlFormatter
#     alias_method :base_format_backtrace, :format_backtrace
#     def format_backtrace(backtrace, example)
#       cramp_log = example.execution_result[:cramp_log]
#       base_format_backtrace(backtrace, example) + 
#         (cramp_log ? 
#         ["-- START SERVER LOG DUMP --"] +
#         cramp_log.split("\n") +
#         ["-- END SERVER LOG DUMP --"] : [])
#     end
#   end
# end
# 
# module Net
#   class HTTPResponse
#     def ok?
#       self.kind_of?(Net::HTTPSuccess)
#     end
#   end
# end
# 
# 
# def context_for_cramp_app(&example_group_block)
#   
#   example_group_class = context("cramp app") do
# 
#     before(:all) do 
#       start_server 
#     end
# 
#     after(:all) do
#       stop_server 
#     end
# 
#     before(:each) do
#       clear_server_log
#     end
# 
#     after(:each) do 
#       example.execution_result[:cramp_log] = server_log if example.failed?
#     end
# 
#     def get(path, params = {})
#       Net::HTTP.get_response(URI::HTTP.build({:host => host, :port => port, :path => path, :query => params.to_query}))
#     end
#     
#     def post(path, params = {})
#       Net::HTTP.post_form(uri_for(path), params)
#     end
#     
#     def get_events(path, params = {})
#       EM.run do
#         puts uri_for(path, params).to_s
#         http = EventMachine::HttpRequest.new(uri_for(path, params).to_s).get
#               http.errback { p 'Uh oh'; EM.stop }
#               http.callback {
#                 p http.response_header.status
#                 p http.response_header
#                 p http.response
# 
#                 EventMachine.stop
#               }
#         # source = EventMachine::EventSource.new(uri_for(path, params).to_s)
#         # source.message do |message|
#         #   yield(message)
#         # end
#         # source.start # Start listening
#       end
#     end
#     
#     def server_log
#       @server_output_stream.string
#     end
# 
#     def clear_server_log
#       @server_output_stream.string = ""
#     end
#     
#   private
# 
#     def host
#       "localhost"
#     end
#     
#     def app # Override to provide your own application.
#       nil
#     end
#     
#     def app_options
#       if app
#         {:app => app}
#       else
#         {:config => "config.ru"}
#       end
#     end
#     
#     def port
#       3001
#     end
#     
#     def uri_for(path, params = {})
#       # I'm using merge here to avoid a trailing question mark in a uri when params hash is empty.
#       URI::HTTP.build({:host => host, :port => port, :path => path}.merge(params != {} ? {:query => params.to_query} : {}))
#     end
#     
#     def start_server
#       # TODO Still logs some stuff to stdout/stderr, e.g.
#       # 127.0.0.1 - - [26/Aug/2011 14:33:32] "GET  HTTP/1.1" 200 - 0.0336
#       # $stdout = ThreadStdOut
#       # $stderr = ThreadStdErr
#       @server_output_stream = StringIO.new
#       
#       @server_thread = Thread.new do
#         Thread.current[:stdout] = @server_output_stream
#         Thread.current[:stderr] = @server_output_stream
#         begin
#           Dir.chdir(File.join(File.dirname(__FILE__), "../../"))
#           options = {:server => 'thin', :Port => port}.merge(app_options)
#           Rack::Server.start(options)
#         rescue => e
#           puts "Error in server thread: #{e}\n#{e.backtrace.join("\n")}"
#           throw
#         end
#       end
#       @server_thread.run
#       # TODO Ugly: simply sleep for some time.
#       sleep(3)
#     end
#     
#     def stop_server
#       $stdout = STDOUT
#       $stderr = STDERR
#       @server_thread.kill if @server_thread
#     end
#   end
#   example_group_class.class_eval &example_group_block
# end
