require "rubygems"
require "bundler"

module CrampApp
  class Application

    def self.root(path = nil)
      @_root ||= File.expand_path(File.dirname(__FILE__))
      path ? File.join(@_root, path.to_s) : @_root
    end

    def self.env
      @_env ||= ENV['RACK_ENV'] || 'development'
    end

    def self.routes
      @_routes ||= eval(File.read('./config/routes.rb'))
    end

    # Initialize the application
    def self.initialize!
    end
    
    def self.find_game
      @game ||= Game.new
      @game
    end
    
    # Clear entire application state -- testing only!
    def self.clear!
      @game = Game.new
    end

  end
end

Bundler.require(:default, CrampApp::Application.env)

# Preload application classes
# puts File.join(File.dirname(__FILE__), 'app/**/*.rb')
Dir[File.join(File.dirname(__FILE__), 'app/**/*.rb')].each {|f| require f}
