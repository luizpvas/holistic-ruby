# frozen_string_literal: true

describe ::Holistic::Ruby::Namespace::Record do
  describe ".new" do
    it "initializes the namespace with the arguments + defaults" do
      namespace = described_class.new(kind: ::Holistic::Ruby::Namespace::Kind::MODULE, name: "MyModule", parent: nil)

      expect(namespace).to have_attributes(
        kind: ::Holistic::Ruby::Namespace::Kind::MODULE,
        name: "MyModule",
        parent: nil,
        children: [],
        locations: []
      )
    end
  end

  describe "#fully_qualified_name" do
    context "when is root namespace" do
      let(:root_namespace) { described_class.new(kind: ::Holistic::Ruby::Namespace::Kind::MODULE, name: "::", parent: nil) }

      it "returns an empty string" do
        expect(root_namespace.fully_qualified_name).to eql("")
      end
    end

    context "when is nested namespace" do
      let(:nested_namespace) do
        root_namespace = described_class.new(kind: ::Holistic::Ruby::Namespace::Kind::MODULE, name: "::", parent: nil)

        parent_namespace = described_class.new(kind: ::Holistic::Ruby::Namespace::Kind::MODULE, name: "ParentModule", parent: root_namespace)

        described_class.new(kind: ::Holistic::Ruby::Namespace::Kind::MODULE, name: "MyModule", parent: parent_namespace)
      end

      it "returns the fully qualified name" do
        expect(nested_namespace.fully_qualified_name).to eql("::ParentModule::MyModule")
      end
    end
  end

  describe "#descendant?" do
    let(:root)      { described_class.new(kind: ::Holistic::Ruby::Namespace::Kind::ROOT, name: "::", parent: nil) }
    let(:child_1)   { described_class.new(kind: ::Holistic::Ruby::Namespace::Kind::MODULE, name: "Child1", parent: root) }
    let(:child_2)   { described_class.new(kind: ::Holistic::Ruby::Namespace::Kind::MODULE, name: "Child2", parent: root) }
    let(:child_2_a) { described_class.new(kind: ::Holistic::Ruby::Namespace::Kind::MODULE, name: "Child2A", parent: child_2) }

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

  describe "#to_symbol" do
    it "builds a symbol from a namespace" do
      location = ::Holistic::Document::Location.beginning_of_file("app.rb")

      namespace = ::Holistic::Ruby::Namespace::Record.new(
        kind: ::Holistic::Ruby::Namespace::Kind::MODULE,
        name: "MyApp",
        parent: ::Holistic::Ruby::Namespace::Record.new(kind: ::Holistic::Ruby::Namespace::Kind::ROOT, name: "::", parent: nil),
        location: location
      )

      expect(namespace.to_symbol).to have_attributes(
        itself: be_a(::Holistic::Ruby::Symbol::Record),
        identifier: namespace.fully_qualified_name,
        kind: :namespace,
        record: namespace,
        locations: [location]
      )
    end
  end
end
