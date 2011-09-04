require File.join(File.dirname(__FILE__), "../../lib/rspec_cramp")
require "cramp"
require "rspec"
require "http_router"

module Cramp
  

    
  describe "rspec-cramp" do
    describe "respond_with matcher", :cramp => true do
      
      class SuccessfulResponse < Cramp::Action
        def start
          render "ok"
          finish
        end
      end
      
      class ErrorResponse < Cramp::Action
        def respond_with
          [500, {'Content-Type' => 'text/html'}]
        end
        def start
          finish
        end
      end
      
      class RaiseOnStart < Cramp::Action
        def start
          raise "an error"
        end
      end
      
      class NoResponse < Cramp::Action
        def start
        end
      end
      
      class CustomHeaders < Cramp::Action
        def respond_with
          [200, {'Extra-Header' => 'ABCD', 'Another-One' => 'QWERTY'}]
        end
        def start
          render "ok"
          finish
        end
      end
      
      # Entry point
      def app
        HttpRouter.new do
          add('/200').to SuccessfulResponse
          add('/500').to ErrorResponse
          add('/no_response').to NoResponse
          add('/custom_header').to CustomHeaders
          add('/raise_on_start').to RaiseOnStart
        end
      end
      
      # get("/url")
      # get("/url").should respond_with :status => 500
      # get("/url") do |status, headers, body|
      # end
  
      shared_examples_for "async_request" do |method|

        describe "timeout" do
          it "- timeout when no response" do
            lambda { send(method, "/no_response") }.should raise_error Timeout::Error
          end
          it "- allow the timeout to be defined by the user" do
            lambda do
              timeout(2) do
                lambda {send(method, "/no_response", {:timeout => 1}) }.should raise_error Timeout::Error
              end
            end.should_not raise_error Timeout::Error
          end
        end
        
        # TODO Rewrite the repetitive code below using data-based spec generation.
        
        describe "exact match on response status" do
          it "should match successful response" do
            send(method, "/200").should respond_with :status => 200
            send(method, "/200").should respond_with :status => "200"
            send(method, "/200").should respond_with :status => :ok
          end
          it "should match error response" do
            send(method, "/500").should respond_with :status => 500
            send(method, "/500").should respond_with :status => "500"
            send(method, "/500").should respond_with :status => :error
            send(method, "/500").should_not respond_with :status => 200
            send(method, "/500").should_not respond_with :status => "200"
            send(method, "/500").should_not respond_with :status => :ok
          end
          it "should match non-async errors from http router" do
            send(method, "/404").should respond_with :status => 404
            send(method, "/404").should respond_with :status => "404"
          end
        end

        describe "regex match on response status" do
          it "should match successful response" do
            send(method, "/200").should respond_with :status => /^2.*/
          end
          it "should match error response" do
            send(method, "/500").should respond_with :status => /^5.*/
            send(method, "/500").should_not respond_with :status => /^2.*/
          end
          it "should match non-sync errors from http router" do
            send(method, "/404").should respond_with :status => /^4.*/
          end
        end
        
        describe "exact match on response headers" do
          it "should match with one expected header" do
            send(method, "/custom_header").should respond_with :header => {"Extra-Header" => "ABCD"}
          end
          it "should match all with two expected headers" do
            send(method, "/custom_header").should respond_with :header => {"Extra-Header" => "ABCD", "Another-One" => "QWERTY"}
          end
          it "should not match if value does not match" do
            send(method, "/custom_header").should_not respond_with :header => {"Extra-Header" => "1234"}
          end
          it "should not match iff both expected headers do not match" do
            send(method, "/custom_header").should_not respond_with :header => {"Extra-Header" => "1234", "Non-Existent-One" => "QWERTY"}
          end
        end
        
        describe "regex match on response headers" do
          it "should match with one expected header" do
            send(method, "/custom_header").should respond_with :header => {"Extra-Header" => /^ABCD$/}
          end
          it "should match all with two expected headers" do
            send(method, "/custom_header").should respond_with :header => {"Extra-Header" => /^ABCD$/, "Another-One" => /^QWERTY$/}
          end
          it "should not match if value does not match" do
            send(method, "/custom_header").should_not respond_with :header => {"Extra-Header" => /^1234$/}
          end
          it "should not match iff both expected headers do not match" do
            send(method, "/custom_header").should_not respond_with :header => {"Extra-Header" => /^1234$/, "Non-Existent-One" => /^QWERTY$/}
          end
        end
        
        # FIXME How to handle a situation where nothing is rendered? get reads the body...
        
        describe "exact match on response body" do
          it "should match with successful response" do
            send(method, "/200").should respond_with :body => "ok"
            send(method, "/200").should_not respond_with :body => "wrong"
          end
          it "should match error response"
          it "should match non-async response from http router"
        end
        describe "regex match on response body" do
          it "should match with successful response"
          it "should match error response"
          it "should match non-async response from http router"
        end          
   
        describe "exact match on response body chunks" do
          it "should match with successful response"
          it "should match error response"
          it "should match non-async response from http router"
        end
        describe "regex match on response body chunks" do
          it "should match with successful response"
          it "should match error response"
          it "should match non-async response from http router"
        end
        
        it "should correctly handle exception in the callbacks"
        it "should correctly handle exception raised in on_start" do
          get("/raise_on_start").should respond_with :code => 200
        end
        
        it "should support custom request headers"
        
        
        it "- support passing extra headers"

      end
          
      describe "GET request" do
        it_should_behave_like "async_request", :get 
      end
    end
  end
end