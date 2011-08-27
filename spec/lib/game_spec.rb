require File.join(File.dirname(__FILE__), "../spec_helper.rb")
require File.join(File.dirname(__FILE__), "../../lib/game.rb")

describe Game do
  describe "should render events using provided rendering method" do
    let(:game) {Game.new}
    let(:renderer) {mock("renderer")}

    context "with no tiles" do
      it "should render nothing" do
        renderer.should_not_receive(:render_tiles)
        game.render(renderer)
      end
    end

    context "with some tiles" do

      let(:lorem) {"Lorem"}
      let(:ipsum) {"ipsum"}

      it "should render all tiles" do
        game.add_tile(lorem)
        game.add_tile(ipsum)
        renderer.should_receive(:render_tiles).with([lorem, ipsum])
        game.render(renderer)
      end
      
      it "eu" do
        for_at_most(1) do
          sleep(20)
        end
      end
    end
  end
end