require File.join(File.dirname(__FILE__), "../spec_helper.rb")
require File.join(File.dirname(__FILE__), "../../lib/game.rb")

describe Game do
  before(:each) do
    Game.destroy_all!
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
    before(:each) do
      @state = GameState.new
      GameState.stub!(:new).once.and_return(@state)
    end    
    it "should create a new game" do
      Game.create("Joe").should be_kind_of Game
    end
    it "should notify events" do 
      @state.should_receive(:join_owner)
      Game.create("Joe")
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
  
  describe "when asked to render" do
    before(:each) do
      @state = mock("state").as_null_object
      GameState.stub!(:new).and_return(@state)
      @game = Game.create("Joe")
      @renderer = mock("renderer")
    end
    it "should ask state to render itself" do
      @state.should_receive(:render_using).with(@renderer)
      @game.render(@renderer)
    end
    it "should pass on the return value from state" do
      @state.stub!(:render_using).and_return("return value")
      @game.render(@renderer).should == "return value"
    end
  end
  
  describe "when a player joins" do
    let(:game) { Game.create("Joe") }
    it "should return the player's private id" do
      game.join("Tim").should == game.private_id("Tim")
    end
  end
  
  describe "when asked to add tiles given a game id" do
    # I'm not using let here because the second game needs to have its game state stubbed.
    it "should ask game state to change" do
      game = Game.create("Joe")
      game.add_tile("Lorem", game.private_id("Joe"))
      game.should have_tile("Lorem")
    end
    it "should not add tiles if game state is not allowed" do
      state = GameState.new
      GameState.stub!(:new).once.and_return(state)
      game = Game.create("Joe")
      state.stub!(:add_tile).and_raise("this state not allowed")
      lambda { game.add_tile("Lorem", game.private_id("Joe")) }.should raise_error
      game.should_not have_tile("Lorem")
    end
  end
end