require File.join(File.dirname(__FILE__), "../spec_helper")


# Context for a cramp application or action; provides support for async get, post etc.
#
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



# Matcher for SSE requeste
#
RSpec::Matchers.define :respond_with_events do |expected_chunks|
  match do |path|
    @result = false
    get_body_chunks path, :count => expected_chunks.size do |actual_chunks|
      @expected_chunks = expected_chunks
      @actual_chunks = actual_chunks
      @result = expected_chunks.zip(actual_chunks).find do |expected, actual|
        (actual =~ /^data: (.*)$/).nil? || $1 != expected
      end.nil? ? true : false
    end
    @result
  end
  failure_message_for_should do
    "expected #{@expected_chunks.inspect} in data but got the following response from server: #{@actual_chunks.inspect}"
  end
end
