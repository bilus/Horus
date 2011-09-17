require File.join(File.dirname(__FILE__), "game_events")
require File.join(File.dirname(__FILE__), "player")
require File.join(File.dirname(__FILE__), "unique_id")

class Game
  @games = []
  def initialize
    @tiles = []
    @players = []
    @public_id = UniqueId.new.to_s
    @events = GameEvents.new
  end
  
  def public_id
    @public_id
  end
  
  def private_id(nick)
    player = @players.find {|p| p.nick == nick }
    raise "No such player: #{nick}" if player.nil?
    
    player.game_id
  end
  
  def join(nick)
    new_player = Player.new(nick)
    @players << new_player
    @events.on_join(nick)
    
    new_player.game_id
  end
  
  def owner_nick
    @owner_nick
  end  
  
  def owner_nick=(nick)
    @players << Player.new(nick)
    @owner_nick = nick
    @events.on_owner(nick)
  end
  
  def render(method)
    @events.render_using(method)
  end
  
  def add_tile(s, game_id = nil)
    raise "Not allowed to play" unless game_id.nil? || interactive?(game_id)
    @tiles << s
    @events.on_add_tile(s)
  end
  
  def has_id?(game_id)
    @public_id == game_id || @players.map {|p| p.game_id}.include?(game_id)
  end

  def interactive?(game_id)
    @players.find {|p| p.game_id == game_id} != nil
  end
  
  # Class methods.
  #
  def self.create(nick)
    new_game = Game.new
    new_game.owner_nick = nick
    @games << new_game
    new_game
  end
  
  def self.find(id)
    @games.find do |game|
      game.has_id?(id)
    end
  end
  
  def self.find_all
    @games
  end
  
  def self.destroy_all!
    @games.clear
  end
end