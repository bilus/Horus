module Cramp
  shared_context "with cramp app", :cramp => true do
    
    before(:all) do 
      @request = Rack::MockRequest.new(app)
    end
    
    def get(path, options = {}, &callback)
      async_get = proc do |path, options, callback|
        puts "y"
        headers = {'async.callback' => callback}
        timeout_secs = options.delete(:timeout) || 5
        timeout(timeout_secs) do
          EM.run do
            catch(:async) do
              puts "eu"
              result = @request.get(path, headers)
              callback.call([result.status, result.header, "Something went wrong"])
            end
          end
        end
      end
      if callback
        async_get.call(path, options, callback)
      else
        {:path => path, :options => {}, :method => async_get}
      end
    end
    
    def stop
      EM.stop
    end
    
    RSpec::Matchers.define :respond_with do |options = {}|
      match do |request|
        # pp request[:method]
        @result = false
        callback = proc do |actual_status, actual_headers, deferred_body|
          puts "there is a response: #{actual_status}"
          expected_status = options.delete(:status)
          @result = expected_status.nil? || expected_status == actual_status
          stop
        end
        request[:method].call(request[:path], callback) 
        @result
      end
    end
  end
end