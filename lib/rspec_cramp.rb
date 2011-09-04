module Cramp
  shared_context "with cramp app", :cramp => true do
    
    before(:all) do 
      @request = Rack::MockRequest.new(app)
    end
    
    def get(path, options = {}, &block)
      async_request = proc do |method, path, options, callback|
        headers = {'async.callback' => callback}
        timeout_secs = options.delete(:timeout) || default_timeout
        timeout(timeout_secs) do
          EM.run do
            catch(:async) do
              result = @request.send(method, path, headers)
              callback.call([result.status, result.header, "Something went wrong"])
            end
          end
        end
      end
      
      if block
        async_request.call(:get, path, options, block)
      else
        max_chunks = options.delete(:max_chunks) || 1
        result = []
        callback = lambda do |response|
          pp response
          puts response[-1].closed?
          result = [response[0], response[1], []]
          stopping = false
          if response[-1].is_a? String
            result[2] << response[-1]
            stop
          elsif response[0].between?(200, 299)
            response[-1].each do |chunk| 
              result[2] << chunk unless stopping
              if result[2].count >= max_chunks
                stopping = true
                EM.next_tick { EM.stop }
              end            
            end
          else
            result[2] = ["Error #{response[0]}"]
            stop
          end
        end
        async_request.call(:get, path, options, callback)
        result
      end
    end
    
    def stop
      EM.stop
    end
    
    def default_timeout
      3
    end
    
    RSpec::Matchers.define :respond_with do |options = {}|
      def match?(actual, expected)
        if expected.nil?
          true  # No expectation set.
        elsif actual.nil?
          false
        elsif expected.is_a? Regexp
          actual.to_s.match(expected)
        elsif expected.is_a? Integer
          actual.to_i == expected
        elsif expected.is_a? String
          actual.to_s == expected
        else
          raise "Unsupported type"
        end
      end
      def resolve_status(status)
        case status
        when :ok then /^2[0-9][0-9]$/
        when :error then /^[^2][0-9][0-9]$/
        else status
        end
      end
      def match_status
        match?(@actual_status, resolve_status(@expected_status))
      end
      def match_headers
        @expected_header.nil? || @expected_header.find do |ek, ev| 
          @actual_headers.find { |ak, av| ak == ek && !match?(av, ev) } != nil
        end == nil 
      end
      def match_body
        match?(@actual_status, @expected_body)
      end
      match do |request_result|
        @expected_status = options.delete(:status)
        @actual_status = request_result[0]
        @expected_header = options.delete(:header)
        @actual_headers = request_result[1]
        @expected_body = options.delete(:body)
        @actual_body = request_result[2]
        match_status && match_headers && match_body
      end
    end
  end
end