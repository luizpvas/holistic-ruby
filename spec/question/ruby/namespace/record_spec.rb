# frozen_string_literal: true

describe ::Question::Ruby::Namespace::Record do
  describe ".new" do
    it "initializes the namespace with the arguments + defaults" do
      namespace = described_class.new(kind: :module, name: "MyModule", parent: nil)

      expect(namespace).to have_attributes(
        kind: :module,
        name: "MyModule",
        parent: nil,
        children: [],
        source_locations: []
      )
    end
  end

  describe "#nest" do
    context "when a namespace with the same name DOES NOT EXIST in the parent namespace" do
      it "adds a new child for each new module" do
        parent = described_class.new(kind: :module, name: "MyModule", parent: nil)

        source_location_1 = ::Question::Ruby::SourceLocation.new
        child_1 = parent.nest(kind: :module, name: "MyChild1", source_location: source_location_1)

        source_location_2 = ::Question::Ruby::SourceLocation.new
        child_2 = parent.nest(kind: :module, name: "MyChild2", source_location: source_location_2)

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
        parent = described_class.new(kind: :module, name: "MyModule", parent: nil)

        child_1 = parent.nest(kind: :module, name: "MyChild", source_location: nil)
        child_2 = parent.nest(kind: :module, name: "MyChild", source_location: nil)

        expect(parent.children.size).to be(1)

        expect(child_1).to be(child_2)
      end

      it "appends the source location to the existing namespace" do
        parent = described_class.new(kind: :module, name: "MyModule", parent: nil)

        source_location_1 = ::Question::Ruby::SourceLocation.new
        source_location_2 = ::Question::Ruby::SourceLocation.new

        parent.nest(kind: :module, name: "MyChild", source_location: source_location_1)
        child = parent.nest(kind: :module, name: "MyChild", source_location: source_location_2)

        expect(child.source_locations).to contain_exactly(source_location_1, source_location_2)
      end
    end
  end
end
