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
      it "should return nil" do
        game.render(renderer).should be_nil
      end
    end

    context "with some tiles" do

      let(:lorem) {"Lorem"}
      let(:ipsum) {"ipsum"}

      before(:each) do
        game.add_tile(lorem)
        game.add_tile(ipsum)
      end
      
      it "should render all tiles" do
        renderer.should_receive(:render_tiles).with([lorem, ipsum])
        game.render(renderer)
      end
      
      it "should pass on the return value from renderer" do
        renderer.stub!(:render_tiles).and_return("return value")
        game.render(renderer).should == "return value"
      end
    end
  end
end