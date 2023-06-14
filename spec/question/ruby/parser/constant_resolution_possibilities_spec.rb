# frozen_string_literal: true

describe ::Question::Ruby::Parser::ConstantResolutionPossibilities do
  describe ".root_scope" do
    it "returns an array with :: as the possibility" do
      expect(described_class.root_scope).to eq(["::"])
    end
  end

  describe "#unshift" do
    it "adds to the front with concated with the previous element" do
      resolution_possibilities = described_class.root_scope

      resolution_possibilities.unshift("Foo")

      expect(resolution_possibilities).to eql(["::Foo", "::"])

      resolution_possibilities.unshift("Bar")

      expect(resolution_possibilities).to eql(["::Foo::Bar", "::Foo", "::"])

      resolution_possibilities.unshift("Qux")

      expect(resolution_possibilities).to eql(["::Foo::Bar::Qux", "::Foo::Bar", "::Foo", "::"])
    end
  end
end
