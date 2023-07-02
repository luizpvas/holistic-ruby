# frozen_string_literal: true

describe ::Holistic::Ruby::Scope::RegisterChildScope do
  context "when a scope with the same name DOES NOT EXIST in the parent scope" do
    it "adds new children" do
      parent = ::Holistic::Ruby::Scope::Record.new(kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "MyModule", parent: nil)

      location_1 = ::Holistic::Document::Location.beginning_of_file("app.rb")
      child_1 = described_class.call(parent: parent, kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "MyChild1", location: location_1)

      location_2 = ::Holistic::Document::Location.beginning_of_file("app.rb")
      child_2 = described_class.call(parent: parent, kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "MyChild2", location: location_2)

      expect(parent.children.size).to be(2)

      expect(child_1).to have_attributes(
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyChild1",
        parent: parent,
        locations: [location_1]
      )

      expect(child_2).to have_attributes(
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyChild2",
        parent: parent,
        locations: [location_2]
      )
    end
  end

  context "when a scope with the same name EXISTS in the parent scope" do
    it "returns the existing scope" do
      parent = ::Holistic::Ruby::Scope::Record.new(kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "MyModule", parent: nil)

      child_1 = described_class.call(parent:, kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "MyChild", location: nil)
      child_2 = described_class.call(parent:, kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "MyChild", location: nil)

      expect(parent.children.size).to be(1)

      expect(child_1).to be(child_2)
    end

    it "appends the source location to the existing scope" do
      parent = ::Holistic::Ruby::Scope::Record.new(kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "MyModule", parent: nil)

      location_1 = ::Holistic::Document::Location.beginning_of_file("app.rb")
      location_2 = ::Holistic::Document::Location.beginning_of_file("app.rb")

      child_from_call_1 = described_class.call(parent:, kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "MyChild", location: location_1)
      child_from_call_2 = described_class.call(parent:, kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "MyChild", location: location_2)

      expect(child_from_call_1).to be(child_from_call_2)

      expect(child_from_call_2.locations).to contain_exactly(location_1, location_2)
    end
  end
end