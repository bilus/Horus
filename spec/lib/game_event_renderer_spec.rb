require File.join(File.dirname(__FILE__), "../../lib/game_event_renderer.rb")

describe GameEventRenderer do
  let(:surface) { mock("surface").as_null_object }
  let(:renderer) { GameEventRenderer.new(surface) }
  
  it "should not call render if no tiles" do
    surface.should_not_receive(:render)
    renderer.render_tiles([])
  end
  
  it "should render tiles using separate render calls" do
    surface.should_receive(:render).once.with("Lorem")
    surface.should_receive(:render).once.with("ipsum")
    renderer.render_tiles(["Lorem", "ipsum"])
  end
end
