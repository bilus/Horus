require File.join(File.dirname(__FILE__), "../../lib/game_event_renderer.rb")

describe GameEventRenderer do
  let(:surface) { mock("surface").as_null_object }

  context "when asked to render events" do
    context "with no previous state" do
      let(:renderer) { GameEventRenderer.new(surface) }

      it "should not call render if no events" do
        surface.should_not_receive(:render_event)
        renderer.render_events([])
      end

      it "should render events using separate render calls" do
        surface.should_receive(:render_event).once.with({:tile => "Lorem"}, anything)
        surface.should_receive(:render_event).once.with({:tile => "ipsum"}, anything)
        renderer.render_events([{:tile => "Lorem"}, {:tile => "ipsum"}])
      end

      it "should render any events" do
        surface.should_receive(:render_event).once.with({:owner => "Joe"}, anything)
        surface.should_receive(:render_event).once.with({:joined => "Tim"}, anything)
        renderer.render_events([{:owner => "Joe"}, {:joined => "Tim"}])
      end

      it "should always pass state to render calls as an integer" do
        surface.should_receive(:render_event) do |event, state|
          state.should be_kind_of Integer
        end
        renderer.render_events([{:tile => "Lorem"}])
      end
    end

    context "with previous state" do
      let(:previous_state) { GameEventRenderer.new(surface).render_events([{:tile => "Lorem"}, {:tile => "ipsum"}]) }
      let(:renderer) { GameEventRenderer.new(surface, previous_state) }

      it "should render new events if given previous state" do
        surface.should_receive(:render_event).once.with({:tile => "dolor"}, anything)
        surface.should_receive(:render_event).once.with({:tile => "sit"}, anything)
        surface.should_receive(:render_event).once.with({:tile => "amet"}, anything)
        renderer.render_events([{:tile => "Lorem"}, {:tile => "ipsum"}, {:tile => "dolor"}, {:tile => "sit"}, {:tile => "amet"}])    
      end

      it "should return updated state" do
        renderer.render_events([{:tile => "Lorem"}, {:tile => "ipsum"}]).should_not be_nil
      end

      it "should increase state with every call to render_events" do
        last_state = renderer.render_events([{:tile => "Lorem"}, {:tile => "ipsum"}, {:tile => "dolor"}])
        new_renderer = GameEventRenderer.new(surface, last_state)
        surface.should_receive(:render_event).twice do |tile, state| 
          state.should > last_state
        end
        new_renderer.render_events([{:tile => "Lorem"}, {:tile => "ipsum"}, {:tile => "dolor"}, {:tile => "sit"}, {:tile => "amet"}])
      end
    end
  end
end
