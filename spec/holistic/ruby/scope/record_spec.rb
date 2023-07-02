# frozen_string_literal: true

describe ::Holistic::Ruby::Scope::Record do
  describe ".new" do
    it "initializes the scope with the arguments + defaults" do
      scope = described_class.new(kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "MyModule", parent: nil)

      expect(scope).to have_attributes(
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyModule",
        parent: nil,
        children: [],
        locations: []
      )
    end
  end

  describe "#fully_qualified_name" do
    context "when scope is root" do
      let(:root_scope) { described_class.new(kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "::", parent: nil) }

      it "returns an empty string" do
        expect(root_scope.fully_qualified_name).to eql("")
      end
    end

    context "when scope is nested inside another scope" do
      let(:nested_scope) do
        root_scope = described_class.new(kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "::", parent: nil)

        parent_scope = described_class.new(kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "ParentModule", parent: root_scope)

        described_class.new(kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "MyModule", parent: parent_scope)
      end

      it "returns the fully qualified name" do
        expect(nested_scope.fully_qualified_name).to eql("::ParentModule::MyModule")
      end
    end
  end

  describe "#descendant?" do
    let(:root)      { described_class.new(kind: ::Holistic::Ruby::Scope::Kind::ROOT, name: "::", parent: nil) }
    let(:child_1)   { described_class.new(kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "Child1", parent: root) }
    let(:child_2)   { described_class.new(kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "Child2", parent: root) }
    let(:child_2_a) { described_class.new(kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "Child2A", parent: child_2) }

    it "returns false for itself" do
      expect(child_1.descendant?(child_1)).to be(false)
      expect(root.descendant?(root)).to be(false)
    end

    it "returns true for direct children" do
      expect(child_1.descendant?(root)).to be(true)
      expect(child_2.descendant?(root)).to be(true)
    end

    it "returns true for children of children recursively" do
      expect(child_2_a.descendant?(root)).to be(true)
    end

    it "returns false scope is not present in ancestry tree" do
      expect(child_1.descendant?(child_2)).to be(false)
      expect(child_2.descendant?(child_1)).to be(false)
      expect(child_2_a.descendant?(child_1)).to be(false)
      expect(root.descendant?(child_1)).to be(false)
    end
  end

  describe "#to_symbol" do
    it "builds a symbol with the scope attributes" do
      location = ::Holistic::Document::Location.beginning_of_file("app.rb")

      scope = ::Holistic::Ruby::Scope::Record.new(
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyApp",
        parent: ::Holistic::Ruby::Scope::Record.new(kind: ::Holistic::Ruby::Scope::Kind::ROOT, name: "::", parent: nil),
        location: location
      )

      expect(scope.to_symbol).to have_attributes(
        itself: be_a(::Holistic::Ruby::Symbol::Record),
        identifier: scope.fully_qualified_name,
        kind: :scope,
        record: scope,
        locations: [location]
      )
    end
  end
end
