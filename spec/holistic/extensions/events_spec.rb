# frozen_string_literal: true

describe ::Holistic::Extensions::Events do
  let(:events) { described_class.new }

  describe "#bind" do
    context "when event exists" do
      it "binds the listener to the event" do
        events.bind(:resolve_method_call_known_scope) { nil }
      end
    end

    context "when event does not exist" do
      it "raises an error" do
        expect {
          events.bind(:unknown_event)
        }.to raise_error(described_class::UnknownEvent)
      end
    end
  end

  describe "#dispatch" do
    context "when event has no listeners" do
      it "returns nil" do
        result = events.dispatch(:resolve_method_call_known_scope, {
          reference: nil,
          referenced_scope: nil,
          method_call_clue: nil
        })

        expect(result).to be_nil
      end
    end

    context "when event params do not match expected format" do
      it "raises an error" do
        expect {
          events.dispatch(:resolve_method_call_known_scope, {})
        }.to raise_error(described_class::MissingRequiredParam)
      end
    end

    context "when output does not match expected type" do
      it "raises an error" do
        events.bind(:resolve_method_call_known_scope) do |**args|
          "this is a string"
        end

        expect {
          events.dispatch(:resolve_method_call_known_scope, {
            reference: nil,
            referenced_scope: nil,
            method_call_clue: nil
          })
        }.to raise_error(described_class::UnexpectedOutput)
      end
    end

    context "when an event has multiple listeners" do
      it "stops on the first listeners that returns a non-nil value" do
        calls = []
        output = ::Holistic::Ruby::Scope::Record.new(kind: ::Holistic::Ruby::Scope::Kind::ROOT, name: "::", parent: nil)

        events.bind(:resolve_method_call_known_scope) do |_params|
          calls << "first"

          nil
        end

        events.bind(:resolve_method_call_known_scope) do |_params|
          calls << "second"

          output
        end

        events.bind(:resolve_method_call_known_scope) do |_params|
          calls << "third"

          nil
        end

        result = events.dispatch(:resolve_method_call_known_scope, {
          reference: nil,
          referenced_scope: nil,
          method_call_clue: nil
        })

        expect(calls).to eql(["first", "second"])
        expect(result).to be(output)
      end
    end
  end
end
