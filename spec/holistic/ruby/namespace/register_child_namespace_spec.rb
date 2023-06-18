# frozen_string_literal: true

describe ::Holistic::Ruby::Namespace::RegisterChildNamespace do
  context "when a namespace with the same name DOES NOT EXIST in the parent namespace" do
    it "adds a new child for each new module" do
      parent = ::Holistic::Ruby::Namespace::Record.new(kind: :module, name: "MyModule", parent: nil)

      source_location_1 = ::Holistic::SourceCode::Location.new
      child_1 = described_class.call(parent: parent, kind: :module, name: "MyChild1", source_location: source_location_1)

      source_location_2 = ::Holistic::SourceCode::Location.new
      child_2 = described_class.call(parent: parent, kind: :module, name: "MyChild2", source_location: source_location_2)

      expect(parent.children.size).to be(2)

      expect(child_1).to have_attributes(
        kind: :module,
        name: "MyChild1",
        parent: parent,
        source_locations: [source_location_1]
      )

      expect(child_2).to have_attributes(
        kind: :module,
        name: "MyChild2",
        parent: parent,
        source_locations: [source_location_2]
      )
    end
  end

  context "when a namespace with the same name EXISTS in the parent namespace" do
    it "returns the existing namespace" do
      parent = ::Holistic::Ruby::Namespace::Record.new(kind: :module, name: "MyModule", parent: nil)

      child_1 = described_class.call(parent:, kind: :module, name: "MyChild", source_location: nil)
      child_2 = described_class.call(parent:, kind: :module, name: "MyChild", source_location: nil)

      expect(parent.children.size).to be(1)

      expect(child_1).to be(child_2)
    end

    it "appends the source location to the existing namespace" do
      parent = ::Holistic::Ruby::Namespace::Record.new(kind: :module, name: "MyModule", parent: nil)

      source_location_1 = ::Holistic::SourceCode::Location.new
      source_location_2 = ::Holistic::SourceCode::Location.new

      child_from_call_1 = described_class.call(parent:, kind: :module, name: "MyChild", source_location: source_location_1)
      child_from_call_2 = described_class.call(parent:, kind: :module, name: "MyChild", source_location: source_location_2)

      expect(child_from_call_1).to be(child_from_call_2)

      expect(child_from_call_2.source_locations).to contain_exactly(source_location_1, source_location_2)
    end
  end
end