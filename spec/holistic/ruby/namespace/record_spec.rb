# frozen_string_literal: true

describe ::Holistic::Ruby::Namespace::Record do
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

  describe "#fully_qualified_name" do
    context "when is root namespace" do
      let(:root_namespace) { described_class.new(kind: :module, name: "::", parent: nil) }

      it "returns an empty string" do
        expect(root_namespace.fully_qualified_name).to eql("")
      end
    end

    context "when is nested namespace" do
      let(:nested_namespace) do
        root_namespace = described_class.new(kind: :module, name: "::", parent: nil)

        parent_namespace = described_class.new(kind: :module, name: "ParentModule", parent: root_namespace)

        described_class.new(kind: :module, name: "MyModule", parent: parent_namespace)
      end

      it "returns the fully qualified name" do
        expect(nested_namespace.fully_qualified_name).to eql("::ParentModule::MyModule")
      end
    end
  end

  describe "#descendant?" do
    let(:root)      { described_class.new(kind: :root, name: "::", parent: nil) }
    let(:child_1)   { described_class.new(kind: :module, name: "Child1", parent: root) }
    let(:child_2)   { described_class.new(kind: :module, name: "Child2", parent: root) }
    let(:child_2_a) { described_class.new(kind: :module, name: "Child2A", parent: child_2) }

    it "returns false for itself" do
      expect(child_1.descendant?(child_1)).to be(false)
      expect(root.descendant?(root)).to be(false)
    end

    it "returns true for direct child" do
      expect(child_1.descendant?(root)).to be(true)
      expect(child_2.descendant?(root)).to be(true)
    end

    it "returns true for children of child (recursively)" do
      expect(child_2_a.descendant?(root)).to be(true)
    end

    it "returns false namespace is not present in ancestry tree" do
      expect(child_1.descendant?(child_2)).to be(false)
      expect(child_2.descendant?(child_1)).to be(false)
      expect(child_2_a.descendant?(child_1)).to be(false)
      expect(root.descendant?(child_1)).to be(false)
    end
  end

  describe "#nest" do
    context "when a namespace with the same name DOES NOT EXIST in the parent namespace" do
      it "adds a new child for each new module" do
        parent = described_class.new(kind: :module, name: "MyModule", parent: nil)

        source_location_1 = ::Holistic::SourceCode::Location.new
        child_1 = parent.nest(kind: :module, name: "MyChild1", source_location: source_location_1)

        source_location_2 = ::Holistic::SourceCode::Location.new
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

        source_location_1 = ::Holistic::SourceCode::Location.new
        source_location_2 = ::Holistic::SourceCode::Location.new

        parent.nest(kind: :module, name: "MyChild", source_location: source_location_1)
        child = parent.nest(kind: :module, name: "MyChild", source_location: source_location_2)

        expect(child.source_locations).to contain_exactly(source_location_1, source_location_2)
      end
    end
  end
end
