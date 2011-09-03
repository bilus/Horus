require File.join(File.dirname(__FILE__), "../spec_helper")


# Context for a cramp application or action; provides support for async get, post etc.
#
def context_for_cramp_app(&example_group_block)
  
  example_group_class = context("cramp app") do

    before(:all) do 
      @request = Rack::MockRequest.new(app)
    end
    
    def get(path, &callback)
      wrapped_callback = proc do |r|
        begin
          callback.call(r)
        rescue 
          stop
          raise $!
        end
      end
      headers = headers.merge('async.callback' => wrapped_callback)

      EM.run do
        catch(:async) do
          result = @request.get(path, headers)
          wrapped_callback.call([result.status, result.header, result.body])
        end
      end
    end

    def get_body(path, options = {}, headers = {}, &block)
      method = options.delete(:method) || :get
      raise "Only :get and :post are supported methods" unless [:get, :post].include?(method)
      callback = options.delete(:callback) || block
      wrapped_callback = proc do |r|
        begin
          callback.call(r) if callback
        rescue 
          stop
          raise $!
        end
      end
      response_callback = proc {|response| response[-1].each {|chunk| wrapped_callback.call(chunk) } }
      send(method, path, options, headers, &response_callback)
    end

    def get_body_chunks(path, options = {}, headers = {}, &block)
      callback = options.delete(:callback) || block
      wrapped_callback = proc do |r|
        begin
          callback.call(r) if callback
        rescue 
          stop
          raise $!
        end
      end
      count = options.delete(:count) || 1

      stopping = false
      chunks = []

      get_body(path, options, headers) do |body_chunk|
        # pp body_chunk
        chunks << body_chunk unless stopping

        if chunks.count >= count
          stopping = true
          wrapped_callback.call(chunks)
          EM.next_tick { EM.stop }
        end
      end
    end
    
    def post(path, options = {}, headers = {}, &block)
      callback = options.delete(:callback) || block
      timeout_secs = options.delete(:timeout) || 5
      wrapped_callback = proc do |r|
        begin
          if callback
            callback.call(r) 
          else
            r[-1].each { stop } # For some reason w/o reading the body, post methods fail.
          end
        rescue 
          stop
          raise $!
        end
      end      
      headers = headers.merge('async.callback' => wrapped_callback)
      
      timeout(timeout_secs) do
        EM.run do
          catch(:async) do 
            result = @request.post(path, headers) 
            wrapped_callback.call([result.status, result.header, result.body])
          end
        end
      end
    end
    
    def stop
      EM.stop
    end
  end
  
  example_group_class.class_eval &example_group_block
end

# Matcher for get requeste
#
RSpec::Matchers.define :respond_to do |method, options = {}|
  raise "Only :get and :post are supported methods" unless [:get, :post].include?(method)
  @method = method.to_sym
  @code = options.delete(:with_code) || /^2[0-9][0-9]$/
  match do |path|
    @path = path
    @result = false
    send(@method, path, {}, options) do |res|
      @actual_code = res[0]
      if @code.is_a? Regexp
        @result = @actual_code.to_s =~ @code
        @code_str = @code.source
      elsif @code.is_a? String
        @result = @actual_code.to_s == @code
        @code_str = @code
      else
        @result = @actual_code.to_i == @code.to_i
        @code_str = @code.to_s
      end
      stop
    end
    @result
  end
  failure_message_for_should do
    "expected #{@path} to respond to '#{@method.to_s.upcase}' with code #{@code_str} but it responded with #{@actual_code}"
  end
  failure_message_for_should_not do
    "expected #{@path} not to respond to '#{@method.to_s.upcase}' with code #{@code_str} but it responded with #{@actual_code}"
  end
end

# Matcher for all requeste
#
RSpec::Matchers.define :respond_with_body do |expected_body, options = {}|
  on_each = options.delete(:on_each)
  method = options.delete(:method)
  headers = (last_event_id = options.delete(:last_event_id)) ? {"HTTP_LAST_EVENT_ID" => last_event_id} : {}
  timeout = options.delete(:timeout) || 5
  
  def match_chunk(actual, expected)
    if actual.nil?
      false
    elsif expected.is_a? Regexp
      actual.match(expected)
    else
      actual == expected
    end
  end
  
  match do |path|
    @result = false
    @expected_body = expected_body
    @expected_chunks = [expected_body]
    
    begin
      timeout(timeout) do
        get_body_chunks path, {:count => @expected_chunks.size, :method => method}, headers do |actual_chunks|
          @actual_chunks = actual_chunks
          @result = @expected_chunks.zip(actual_chunks).find do |expected, actual|
            !match_chunk(actual, expected)
          end.nil? ? true : false
        end
      end
    rescue Timeout::Error
      @actual_chunks = "Timeout"
    end
    @result
  end
  failure_message_for_should do
    "expected #{@expected_body.inspect} in body but got the following response from server: #{@actual_chunks.inspect}"
  end
end


# Matcher for SSE requeste
#
RSpec::Matchers.define :respond_with_events do |expected_chunks, options = {}|;
  
  def match_data(actual, expected)
    if actual.nil?
      false
    elsif expected.is_a? Regexp
      actual.match(expected)
    else
      actual == expected
    end
  end
  
  def parse_response(chunk)
    data = (chunk =~ /^data: (.*)$/).nil? ? "" : $1
    event_id = (chunk =~ /^id: (.*)$/).nil? ? "" : $1
    [data, event_id]
  end
  
  on_each = options.delete(:on_each)
  headers = (last_event_id = options.delete(:last_event_id)) ? {"HTTP_LAST_EVENT_ID" => last_event_id} : {}
  timeout = options.delete(:timeout) || 5
  
  match do |path|
    @result = false
    @expected_chunks = expected_chunks
    begin
      timeout(timeout) do
        get_body_chunks path, {:count => expected_chunks.size}, headers do |actual_chunks|
          @actual_chunks = actual_chunks
          @result = expected_chunks.zip(actual_chunks).find do |expected, actual|
            data, event_id = parse_response(actual)
            on_each.call(data, event_id) unless on_each.nil?
            !match_data(data, expected)
          end.nil? ? true : false
        end
      end
    rescue Timeout::Error
      @actual_chunks = "Timeout"
    end
    @result
  end
  failure_message_for_should do
    "expected #{@expected_chunks.inspect} in data but got the following response from server: #{@actual_chunks.inspect}"
  end
end
