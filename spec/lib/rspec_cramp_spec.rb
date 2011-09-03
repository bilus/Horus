require File.join(File.dirname(__FILE__), "../../lib/rspec_cramp")
require "cramp"
require "rspec"
require "http_router"

module Cramp
  
  $stdout.sync = true
  
  describe "rspec support for cramp" do
    describe "respond_with", :cramp => true do
      def app
        HttpRouter.new do
          def simple_cramp_action(&response)
            Class.new(Cramp::Action) do
              define_method(:start) do
                response.call
              end
            end
          end

          def respond_with_cramp_action(&response)
            Class.new(Cramp::Action) do
              define_method(:respond_with) do
                response.call
              end
            end
          end

          add('/200').to(simple_cramp_action do
            render "ok"
            finish
          end)
          add('/500').to(respond_with_cramp_action do
            [500, {'Content-Type' => 'text/html'}]
          end)
          add('/no_response').to(simple_cramp_action do
            end)
        end
      end
      
      # get("/url")
      # get("/url").should respond_with :status => 500
      # get("/url") do |status, headers, body|
      # end
  
      shared_examples_for "async_request_method" do |method|
        it "should handle successful response" do
          send(method, "/200", {}).should respond_with :status => 200
        end
        it "should handle error response" do
          send(method, "/500", {}).should respond_with :status => 500
          send(method, "/500", {}).should_not respond_with :status => 200
        end
        it "should handle sync errors from http router" do
          send(method, "/404", {}).should respond_with :status => 404
        end
        
        it "should timeout when no response" do
          lambda { send(method, "/no_response", {}) }.should raise_error Timeout::Error
        end
        it "should allow the timeout to be defined by the user" do
          lambda do
            timeout(2) do
              lambda {send(method, "/no_response", {:timeout => 1}) }.should raise_error Timeout::Error
            end
          end.should_not raise_error Timeout::Error
        end

      end
          
      describe "GET request method" do
        it_should_behave_like "async_request_method", :get 
      end
    end
  end
end