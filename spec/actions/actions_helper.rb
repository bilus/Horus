require 'net/http'
require 'active_support/core_ext/object/to_query'

##
# Allows $stdout to be set via Thread.current[:stdout] per thread.
module ThreadStdOut

  def self.write(stuff)
    stream.write stuff

  end

  def self.<<(stuff)
    stream << stuff
  end
  
  def self.puts(stuff)
    stream.puts(stuff)
  end
  
  private
  
  def self.stream
    raise "error" unless Thread.current[:stdout]
    
    Thread.current[:stdout] || STDOUT
  end

end

##
# Allows $stderr to be set via Thread.current[:stderr] per thread.
module ThreadStdErr
  
  def self.write(stuff)
    stream.write stuff

  end

  def self.<<(stuff)
    stream << stuff
  end
  
  def self.puts(stuff)
    stream.puts(stuff)
  end
  
  private
  
  def self.stream
    raise "error" unless Thread.current[:stderr]
    
    Thread.current[:stderr] || STDERR
  end

end

##
# Monkey-patch rspec to allow to check example status in after(:each)
class RSpec::Core::Example
  attr_reader :exception
  
  def passed?
    @exception.nil?
  end
  
  def failed?
    !passed?
  end
end

require 'rspec/core/formatters/base_text_formatter'

module RSpec::Core::Formatters
  class BaseTextFormatter
    alias_method :base_dump_failure, :dump_failure
    def dump_failure(example, index)
      base_dump_failure(example, index)
      output.puts "__ START SERVER LOG DUMP --\n" 
      output.puts example.execution_result[:cramp_log]
      output.puts "-- END SERVER LOG DUMP --"
      output.flush
    end
  end
end

require 'rspec/core/formatters/html_formatter'

module RSpec::Core::Formatters
  class HtmlFormatter
    alias_method :base_format_backtrace, :format_backtrace
    def format_backtrace(backtrace, example)
      base_format_backtrace(backtrace, example) + 
        ["-- START SERVER LOG DUMP --"] +
        example.execution_result[:cramp_log].split("\n") +
        ["-- END SERVER LOG DUMP --"]
    end
  end
end

module Net
  class HTTPResponse
    def ok?
      self.kind_of?(Net::HTTPSuccess)
    end
  end
end


def context_for_cramp_app(&example_group_block)
  
  example_group_class = context("cramp app") do

    before(:all) do 
      start_server 
    end

    after(:all) do
      stop_server 
    end

    before(:each) do
      clear_server_log
    end

    after(:each) do 
      example.execution_result[:cramp_log] = server_log if example.failed?
    end

    def get(path, params = {})
      Net::HTTP.get_response(URI::HTTP.build({:host => host, :port => port, :path => path, :query => params.to_query}))
    end
    
    def post(path, params = {})
      Net::HTTP.post_form(URI.parse(uri_for(path)), params)
    end
    
    def server_log
      @server_output_stream.string
    end

    def clear_server_log
      @server_output_stream.string = ""
    end
    
  private

    def host
      "localhost"
    end
    
    def app # Override to provide your own application.
      nil
    end
    
    def app_options
      if app
        {:app => app}
      else
        {:config => "config.ru"}
      end
    end
    
    def port
      3001
    end
    
    def uri_for(path)
      "http://" + File.join(host + ":" + port.to_s, path)
    end
    
    def start_server
      $stdout = ThreadStdOut
      $stderr = ThreadStdErr
      @server_output_stream = StringIO.new
      
      @server_thread = Thread.new do
        Thread.current[:stdout] = @server_output_stream
        Thread.current[:stderr] = @server_output_stream
        begin
          Dir.chdir(File.join(File.dirname(__FILE__), "../../"))
          options = {:server => 'thin', :Port => port}.merge(app_options)
          Rack::Server.start(options)
        rescue => e
          puts "Error in server thread: #{e}\n#{e.backtrace}"
          throw
        end
      end
      @server_thread.run
      # TODO Ugly: simply sleep for some time.
      sleep(2)
    end
    
    def stop_server
      $stdout = STDOUT
      $stderr = STDERR
      @server_thread.kill if @server_thread
    end
  end
  example_group_class.class_eval &example_group_block
end
