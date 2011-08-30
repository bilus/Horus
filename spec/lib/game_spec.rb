require File.join(File.dirname(__FILE__), "../spec_helper.rb")
require File.join(File.dirname(__FILE__), "../../lib/game.rb")

describe Game do
  
  describe "should report on its state" do
    context "empty game" do
      subject { Game.new }
      it { should_not have_tiles }
    end
    context "non-empty game" do
      subject { g = Game.new; g.add_tile("Lorem"); g }
      it { should have_tiles }
    end
  end
  
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
  
  describe "after a game is started" do
    subject { g = Game.new; g.add_tile("Lorem"); g }
    let(:renderer) {mock("renderer")}
    before(:each) { subject.start! }
    it { should_not have_tiles }
    it "should render nothing" do
      renderer.should_not_receive(:render_tiles)
      subject.render(renderer)
    end
  end
  
end