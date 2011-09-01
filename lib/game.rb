require 'uuidtools'

class Game
  @games = {}
  def initialize
    @tiles = []
    # FIXME Extract into UniqueGameId class.
    seed = UUIDTools::UUID.random_create
    @id = UUIDTools::UUID.md5_create(UUIDTools::UUID_DNS_NAMESPACE, "www.xtreeme.com/#{seed}")
  end
  
  def id
    @id.to_s
  end
  
  def self.create
    new_game = Game.new
    @games[new_game.id] = new_game
    new_game
  end
  
  def self.find(id)
    @games[id]
  end
  
  def self.destroy_all!
    @games.clear
  end
  
  def render(method)
    method.render_tiles(@tiles) unless @tiles.empty?
  end
  
  def add_tile(s)
    @tiles << s
  end
  
  def has_tiles?
    !@tiles.empty?
  end
end