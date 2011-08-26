require File.join(File.dirname(__FILE__), "../../lib/game.rb")

describe Game do
  describe "should render events using provided rendering method" do
    before(:each) do
      @game = Game.new
      @renderer = mock("renderer")
    end
    context "with no tiles" do
      it "should render nothing" do
        @renderer.should_not_receive(:render_tiles)
        @game.render(@renderer)
      end
    end
    context "with some tiles" do
      before(:each) do
        @tile1 = "Lorem"
        @tile2 = "Ipsum"
        @game.add_tile(@tile1)
        @game.add_tile(@tile2)
      end
      it "should render all tiles" do
        @renderer.should_receive(:render_tiles).with([@tile1, @tile2])
        @game.render(@renderer)
      end
    end
  end
end