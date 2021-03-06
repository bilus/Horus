require File.join(File.dirname(__FILE__), "../spec_helper.rb")
require File.join(File.dirname(__FILE__), "../../lib/player.rb")
require File.join(File.dirname(__FILE__), "../../lib/game_state.rb")

describe GameState do
  let(:events) { mock("events").as_null_object }
  let(:state) { GameState.new(events) }
  
  describe "when player joins" do
    let(:joe) { Player.new("Joe") }

    it "should call block" do
      block = mock("block")
      block.should_receive(:call)
      state.join(joe, &block.call)
    end
    it "should update events" do
      events.should_receive(:on_join)
      state.join(joe)
    end
    it "should make game interactive for the player" do
      state.join(joe)
      state.should be_interactive(joe.game_id)
    end
  end
  
  describe "when owner joins" do
    let(:joe) { Player.new("Joe") }
    it "should call block" do
      block = mock("block")
      block.should_receive(:call)
      state.join_owner(joe, &block.call)
    end
    it "should update events" do
      events.should_receive(:on_owner)
      events.should_receive(:on_next_turn).with(joe.nick)
      state.join_owner(joe)
    end
    it "should make game interactive for the player" do
      state.join_owner(joe)
      state.should be_interactive(joe.game_id)
    end
  end
  
  describe "when asked to render" do
    it "should ask events to render themselves" do
      surface = mock("surface")
      events.should_receive(:render_using).with(surface)
      state.render_using(surface)
    end
    it "should pass the return value to the caller" do
      surface = mock("surface")
      events.stub!(:render_using).and_return("return value")
      state.render_using(surface).should == "return value"
    end
  end
  
  describe "when asked to add tile" do
    let(:joe) { j = Player.new("Joe"); state.join_owner(j); j }
    context "given a private id" do
      it "should allow this action" do
        lambda { state.add_tile("Lorem", joe.game_id) }.should_not raise_error
      end
      it "should update events" do
        events.should_receive(:on_add_tile)
        state.add_tile("Lorem", joe.game_id)
      end
      it "should call block" do
        block = mock("block")
        block.should_receive(:call)
        state.add_tile("Lorem", joe.game_id, &block.call)
      end
    end
    context "given a non-recognized game id" do
      it "should disallow the action and not update events" do
        events.should_not_receive(:on_add_tile)
        lambda { @game.add_tile("Lorem", "bad id") }.should raise_error
      end
      it "should not call block" do
        block = mock("block")
        block.should_not_receive(:call)
        lambda { state.add_tile("Lorem", joe.game_id, &block.call) }.should raise_error
      end
    end
    context "by players in turns" do
      let!(:owner) { joe }
      let!(:other_player) { p = Player.new("Tim"); state.join(p); p }
      it "should allow the owner to add the first tile" do
        lambda { state.add_tile("Lorem", owner.game_id) }.should_not raise_error
      end
      it "should not allow other players to add the first tile" do
        lambda { state.add_tile("Lorem", other_player.game_id) }.should raise_error
      end
      it "should not allow the owner to add two tiles in a row" do
        state.add_tile("Lorem", owner.game_id)
        lambda { state.add_tile("Lorem", owner.game_id) }.should raise_error
      end
      it "should be the other player's turn after the owner" do
        state.add_tile("Lorem", owner.game_id)
        lambda { state.add_tile("Lorem", other_player.game_id) }.should_not raise_error
      end
      it "should update events" do
        events.should_receive(:on_next_turn).with(other_player.nick)
        state.add_tile("Lorem", owner.game_id)
      end
    end
    context "given only one player" do
      it "should allow the player to add tiles indefinitely" do
        lambda { state.add_tile("Lorem", joe.game_id) }.should_not raise_error
        lambda { state.add_tile("ipsum", joe.game_id) }.should_not raise_error
        lambda { state.add_tile("sit", joe.game_id) }.should_not raise_error
        lambda { state.add_tile("amet", joe.game_id) }.should_not raise_error
      end
    end
  end
  
  describe "when asked to pass turn" do
    context "with one player" do
      # TODO
      # it "should end the turn"
    end
    context "with two players" do
      let(:joe) { Player.new("Joe") }
      let(:tim) { Player.new("Tim") }
      before(:each) do
        state.join_owner(joe)
        state.join(tim)
      end
      context "by the current player" do
        it "pass the turn to the other player" do
          state.pass_turn(joe.game_id)
          lambda { state.add_tile("Lorem", tim.game_id) }.should_not raise_error
        end
        it "should update events" do
          events.should_receive(:on_next_turn).with("Tim")
          state.pass_turn(joe.game_id)
        end
      end
      context "by a player other than the current"
        it "should raise an error" do
          lambda { state.pass_turn(tim.game_id) }.should raise_error
        end
    end
    context "given an invalid id" do
      it "should raise an error" do
        lambda { state.pass_turn("invalid id") }.should raise_error
      end
    end
  end
  
  describe "when asked if can interact" do
    let(:joe) { Player.new("Joe") }
    let(:tim) { Player.new("Tim") }
    subject { s = GameState.new; s.join_owner(tim); s.join(joe); s}
    it { should be_interactive(joe.game_id) }
    it { should be_interactive(tim.game_id) }
    it { should_not be_interactive("bad id") }
  end
end
