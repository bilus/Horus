require File.join(File.dirname(__FILE__), "../spec_helper.rb")
require File.join(File.dirname(__FILE__), "../../lib/game_events.rb")

describe GameEvents do
  describe "when asked to render events" do
    let(:renderer) { mock("renderer") }
    let(:events) { GameEvents.new }
    
    it "should render owner" do
      events.on_owner("Tim")
      renderer.should_receive(:render_events).with([{:owner => "Tim"}])
      events.render_using(renderer)
    end

    it "should render players" do
      events.on_join("Joe")
      renderer.should_receive(:render_events).with([{:join => "Joe"}])
      events.render_using(renderer)
    end

    it "should render tiles" do
      events.on_add_tile("Lorem")
      events.on_add_tile("ipsum")
      renderer.should_receive(:render_events).with([{:tile => "Lorem"}, {:tile => "ipsum"}])
      events.render_using(renderer)
    end

    it "should render all" do
      events.on_owner("Tim")
      events.on_add_tile("Lorem")
      events.on_add_tile("ipsum")
      events.on_join("Joe")
      renderer.should_receive(:render_events).with([{:owner => "Tim"}, {:tile => "Lorem"}, {:tile => "ipsum"}, {:join => "Joe"}])
      events.render_using(renderer)
    end

    it "should pass on the return value from renderer" do
      renderer.stub!(:render_events).and_return("return value")
      events.render_using(renderer).should == "return value"
    end
  end
end
