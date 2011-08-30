require File.join(File.dirname(__FILE__), "../../lib/game_event_renderer.rb")

describe GameEventRenderer do
  let(:surface) { mock("surface").as_null_object }
  
  context "renderer with no previous state" do
    let(:renderer) { GameEventRenderer.new(surface) }
  
    it "should not call render if no tiles" do
      surface.should_not_receive(:render_tile)
      renderer.render_tiles([])
    end
  
    it "should render tiles using separate render calls" do
      surface.should_receive(:render_tile).once.with("Lorem", anything)
      surface.should_receive(:render_tile).once.with("ipsum", anything)
      renderer.render_tiles(["Lorem", "ipsum"])
    end
    
    it "shoulda always pass state to render calls as an integer" do
      surface.should_receive(:render_tile) do |tile, state|
        state.should be_kind_of Integer
      end
      renderer.render_tiles(%w{Lorem]})
    end
  end
  
  context "renderer with previous state" do
    let(:previous_state) { GameEventRenderer.new(surface).render_tiles(%w{Lorem ipsum}) }
    let(:renderer) { GameEventRenderer.new(surface, previous_state) }

    it "should render new tiles if given previous state" do
      surface.should_receive(:render_tile).once.with("dolor", anything)
      surface.should_receive(:render_tile).once.with("sit", anything)
      surface.should_receive(:render_tile).once.with("amet", anything)
      renderer.render_tiles(%w{Lorem ipsum dolor sit amet})    
    end
    
    it "should return updated state" do
      renderer.render_tiles(%w{Lorem ipsum}).should_not be_nil
    end
    
    it "should grow state" do
      last_state = renderer.render_tiles(%w{Lorem ipsum dolor})
      new_renderer = GameEventRenderer.new(surface, last_state)
      surface.should_receive(:render_tile).twice do |tile, state| 
        state.should > last_state
      end
      new_renderer.render_tiles(%w{Lorem ipsum dolor sit amet})
    end
  end
end
