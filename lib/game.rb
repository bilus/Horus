require 'uuidtools'
require File.join(File.dirname(__FILE__), "game_events")

class Game
  @games = []
  def initialize
    @tiles = []
    @ids = {}
    @ids[:public] = generate_unique_id
    @events = GameEvents.new
  end
  
  def public_id
    @ids[:public]
  end
  
  def private_id(nick)
    @ids[nick]
  end
  
  def join(nick)
    private_id = generate_unique_id
    @ids[nick] = private_id
    @events.on_join(nick)
    private_id
  end
  
  def owner_nick
    @owner_nick
  end  
  
  def owner_nick=(nick)
    @ids[nick] = generate_unique_id
    @owner_nick = nick
    @events.on_owner(nick)
  end
  
  def self.create(nick)
    new_game = Game.new
    new_game.owner_nick = nick
    @games << new_game
    new_game
  end
  
  def self.find(id)
    @games.find do |game|
      game.all_ids.index(id)
    end
  end
  
  def self.find_all
    @games
  end
  
  def self.destroy_all!
    @games.clear
  end
  
  def render(method)
    @events.render_using(method)
  end
  
  def add_tile(s, game_id = nil)
    raise "Not allowed to play" unless game_id.nil? || interactive?(game_id)
    @tiles << s
    @events.on_add_tile(s)
  end
  
  def has_tiles?
    !@tiles.empty?
  end
  
  def all_ids
    @ids.values
  end

  def interactive?(game_id)
    @ids.values.include?(game_id) && !public_id?(game_id)
  end

  private  
  
  def public_id?(id)
    @ids[:public] == id
  end
  
  def generate_unique_id
    # FIXME Extract into UniqueGameId class.
    seed = UUIDTools::UUID.random_create
    UUIDTools::UUID.md5_create(UUIDTools::UUID_DNS_NAMESPACE, "www.xtreeme.com/#{seed}").to_s
  end
end