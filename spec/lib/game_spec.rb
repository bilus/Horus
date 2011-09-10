require File.join(File.dirname(__FILE__), "../spec_helper.rb")
require File.join(File.dirname(__FILE__), "../../lib/game.rb")

describe Game do
  before(:each) do
    Game.destroy_all!
  end
  
  def create_game
    Game.create("nickname")
  end
  
  describe "when asked if it has tiles" do
    context "when it's an empty game" do
      subject { Game.new }
      it { should_not have_tiles }
    end
    context "when it's a non-empty game" do
      subject { g = Game.new; g.add_tile("Lorem"); g }
      it { should have_tiles }
    end
  end
  
  describe "when asked for its id" do
    let(:game1) { Game.new } 
    let(:game2) { Game.new } 
    it "should return a non-nil id" do
      game1.id.should_not be_nil
    end
    it "should have a unique id" do
      game1.id.should_not == game2.id
    end
  end
  
  describe "when asked for its owner" do
    let(:game1) { Game.create("Joe") }
    specify { game1.owner_nick.should == "Joe" }
  end
  
  describe "when asked to create a game" do
    it "should create a new game" do
      create_game.should be_kind_of Game
    end
  end
  
  describe "when asked to find a game given its id" do
    let(:game_create1) { create_game } 
    let(:game_create2) { create_game } 
    let(:game_new) { Game.new } 
    it "should find games created using the create method" do
      # Note: in a future version, chances are that Game objects will be pulled out of a database
      # and may be different instances so the equality comparison below won't work.
      Game.find(game_create1.id).should == game_create1
      Game.find(game_create2.id).should == game_create2
    end
    it "should not find games created using the new method" do
      Game.find(game_new).should be_nil
    end
  end
  
  describe "when asked to find all games" do
    let!(:game_create1) { create_game } 
    let!(:game_create2) { create_game } 
    let!(:game_new) { Game.new } 
    it "should find games created using the create method" do
      Game.find_all.map {|game| game.id}.sort.should == [game_create1.id, game_create2.id].sort
    end
    it "should not find games created using the new method" do
      Game.find_all.map {|game| game.id}.should_not include game_new.id
    end
  end
  
  describe "when asked to destroy all games" do
    let!(:game_create1) { create_game } 
    let!(:game_create2) { create_game }    
    it "should be unable to find any games afterwards" do
      Game.destroy_all!
      Game.find(game_create1.id).should be_nil
      Game.find(game_create2.id).should be_nil
    end
  end
  
  describe "when asked to render events" do
    let(:game_owner) {"Joe"}
    let(:game) {Game.create(game_owner)}
    let(:renderer) {mock("renderer")}

    context "with no tiles" do
      it "should render just owner" do
        renderer.should_receive(:render_events).with([{:owner => game_owner}])
        game.render(renderer)
      end
    end

    context "with some tiles" do
      let(:lorem) {"Lorem"}
      let(:ipsum) {"ipsum"}
      before(:each) do
        game.add_tile(lorem)
        game.add_tile(ipsum)
      end
      it "should render owner and all tiles" do
        renderer.should_receive(:render_events).with([{:owner => game_owner}, {:tile => lorem}, {:tile => ipsum}])
        game.render(renderer)
      end
    end

    it "should pass on the return value from renderer" do
      renderer.stub!(:render_events).and_return("return value")
      game.render(renderer).should == "return value"
    end
  end
  
  describe "players may join the game" do
    let(:game) {Game.create("Joe")}
    
    it "should support the join method" do
      game.join("Tim")
    end
  end
end