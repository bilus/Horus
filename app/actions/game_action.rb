require 'json'
require File.join(File.dirname(__FILE__), "../../application.rb")

class GameAction < Cramp::Action
  def find_game
    @game = Horus::Application.find_game(params[:game_id])
    yield
  end

  def render_result(&block)
    begin
      render block.call.to_json
    rescue => e
      render ({:status => :error, :message => e.to_s}).to_json
    end
  end
  
  def request_headers
    @env.inject({}){|acc, (k,v)| acc[$1.downcase] = v if k =~ /^http_(.*)/i; acc}
  end
end
