class Game
  def initialize
    @tiles = []
  end
  def start!
    @tiles = []
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