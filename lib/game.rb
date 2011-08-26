class Game
  def initialize
    @tiles = []
  end
  def render(method)
    method.render_tiles(@tiles) unless @tiles.empty?
  end
  def add_tile(s)
    @tiles << s
  end
end