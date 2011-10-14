require File.join(File.dirname(__FILE__), "game_state")
require File.join(File.dirname(__FILE__), "player")
require File.join(File.dirname(__FILE__), "unique_id")

class Game
  @games = []
  def initialize
    @tiles = []
    @players = []
    @public_id = UniqueId.new.to_s
    @state = GameState.new
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
    @state.join(new_player) do
      @players << new_player
    end
    new_player.game_id
  end
  
  def owner_nick
    @owner_nick
  end  
  
  def owner_nick=(nick)
    new_player = Player.new(nick)
    @state.join_owner(new_player) do
      @players << new_player
      @owner_nick = nick
    end
  end
  
  def render(method)
    @state.render_using(method)
  end
  
  def add_tile(s, game_id = nil)
    @state.add_tile(s, game_id) do
      @tiles << s
    end
  end
  
  def pass_turn(game_id)
    @state.pass_turn(game_id)
  end
  
  def has_tile?(s)  # Testing only.
    @tiles.include?(s)
  end
  
  def has_id?(game_id)
    @public_id == game_id || @players.map {|p| p.game_id}.include?(game_id)
  end
  
  def interactive?(game_id)
    @state.interactive?(game_id)
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