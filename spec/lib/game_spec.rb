require File.join(File.dirname(__FILE__), "../spec_helper.rb")
require File.join(File.dirname(__FILE__), "../../lib/game.rb")

describe Game do
  before(:each) do
    Game.destroy_all!
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
  
  describe "when asked for its public id" do
    let(:game1) { Game.new } 
    let(:game2) { Game.new } 
    it "should return a non-nil id" do
      game1.public_id.should_not be_nil
    end
    it "should have a unique id" do
      game1.public_id.should_not == game2.public_id
    end
  end
  
  describe "when asked for its owner" do
    let(:game1) { Game.create("Joe") }
    specify { game1.owner_nick.should == "Joe" }
  end
  
  describe "when asked to create a game" do
    it "should create a new game" do
      Game.create("Joe").should be_kind_of Game
    end
  end
  
  describe "when asked to find a game given its public id" do
    let(:game_create1) { Game.create("Joe") } 
    let(:game_create2) { Game.create("Tim") } 
    let(:game_new) { Game.new } 
    it "should find games created using the create method" do
      # Note: in a future version, chances are that Game objects will be pulled out of a database
      # and may be different instances so the equality comparison below won't work.
      Game.find(game_create1.public_id).should == game_create1
      Game.find(game_create2.public_id).should == game_create2
    end
    it "should not find games created using the new method" do
      Game.find(game_new.public_id).should be_nil
    end
  end

  describe "when asked to find a game given its creator's private id" do
    let(:game_create1) { Game.create("Joe") } 
    let(:game_create2) { Game.create("Tim") } 
    let(:game_new) { Game.new } 
    it "should find games created using the create method" do
      # Note: in a future version, chances are that Game objects will be pulled out of a database
      # and may be different instances so the equality comparison below won't work.
      Game.find(game_create1.private_id("Joe")).should == game_create1
      Game.find(game_create2.private_id("Tim")).should == game_create2
    end
  end

  describe "when asked to find a game given a player's private id" do
    let(:game_create1) { Game.create("Joe") } 
    let(:game_create2) { Game.create("Tim") } 
    let(:game_new) { Game.new } 
    it "should find games created using the create method" do
      game_create1.join("John")
      game_create2.join("Tommy")
      # Note: in a future version, chances are that Game objects will be pulled out of a database
      # and may be different instances so the equality comparison below won't work.
      Game.find(game_create1.private_id("John")).should == game_create1
      Game.find(game_create2.private_id("Tommy")).should == game_create2
    end
  end
  
  describe "when asked to find all games" do
    let!(:game_create1) { Game.create("Joe") } 
    let!(:game_create2) { Game.create("Tim") } 
    let!(:game_new) { Game.new } 
    it "should find games created using the create method" do
      Game.find_all.map {|game| game.public_id}.sort.should == [game_create1.public_id, game_create2.public_id].sort
    end
    it "should not find games created using the new method" do
      Game.find_all.map {|game| game.public_id}.should_not include game_new.public_id
    end
  end
  
  describe "when asked to destroy all games" do
    let!(:game_create1) { Game.create("Joe") } 
    let!(:game_create2) { Game.create("Tim") }    
    it "should be unable to find any games afterwards" do
      Game.destroy_all!
      Game.find(game_create1.public_id).should be_nil
      Game.find(game_create2.public_id).should be_nil
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
    
    it "should support respond with private game id" do
      game.join("Tim").should == game.private_id("Tim")
    end
  end
  
  describe "when asked to add tiles given a game id" do
    let(:game) {Game.create("Joe")}
    it "should accept a private id" do
      lambda { game.add_tile("Lorem", game.private_id("Joe")) }.should_not raise_error
      game.should have_tiles
    end
    it "should not accept a public id" do
      lambda { game.add_tile("Lorem", game.public_id) }.should raise_error
      game.should_not have_tiles
    end
  end
  
  describe "when asked if can interract" do
    subject { g = Game.create("Joe"); g.join("Tim"); g}
    it { should be_interactive(subject.private_id("Joe")) }
    it { should be_interactive(subject.private_id("Tim")) }
    it { should_not be_interactive(subject.public_id) }
  end
end