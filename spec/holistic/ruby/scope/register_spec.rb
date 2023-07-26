# frozen_string_literal: true

describe ::Holistic::Ruby::Scope::Register do
  concerning :TestHelpers do
    def create_root_scope
      ::Holistic::Ruby::Scope::Record.new(kind: ::Holistic::Ruby::Scope::Kind::ROOT, name: "::", parent: nil)
    end
  end

  context "when a scope with the same name DOES NOT EXIST in the parent scope" do
    let(:repository) { ::Holistic::Ruby::Scope::Repository.new }

    let(:parent) do
      ::Holistic::Ruby::Scope::Record.new(
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyModule",
        parent: create_root_scope
      )
    end

    let(:child_1_location) do
      ::Holistic::Document::Location.beginning_of_file("app.rb")
    end

    let!(:child_1) do
      described_class.call(repository:, parent:, kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "MyChild1", location: child_1_location)
    end

    let(:child_2_location) do
      ::Holistic::Document::Location.beginning_of_file("app.rb")
    end

    let!(:child_2) do
      described_class.call(repository:, parent:, kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "MyChild2", location: child_2_location)
    end

    it "adds new children in the parent scope" do
      expect(parent.children).to match_array([child_1, child_2])

      expect(child_1).to have_attributes(
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyChild1",
        parent: parent
      )

      expect(child_1.locations.items).to match_array([
        child_1_location
      ])

      expect(child_2).to have_attributes(
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyChild2",
        parent: parent
      )

      expect(child_2.locations.items).to match_array([
        child_2_location
      ])
    end

    it "inserts the scope in the repository" do
      expect(repository.table.size).to be(2)

      expect(repository.find_by_fully_qualified_name("::MyModule::MyChild1")).to be(child_1)
      expect(repository.find_by_fully_qualified_name("::MyModule::MyChild2")).to be(child_2)
    end
  end

  context "when a scope with the same name EXISTS in the parent scope" do
    let(:repository) { ::Holistic::Ruby::Scope::Repository.new }

    let(:parent) do
      ::Holistic::Ruby::Scope::Record.new(
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyModule",
        parent: create_root_scope
      )
    end

    let(:location_1) { ::Holistic::Document::Location.beginning_of_file("app.rb") }
    let(:location_2) { ::Holistic::Document::Location.beginning_of_file("app.rb") }

    let!(:child_1) do
      described_class.call(repository:, parent:, kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "MyChild", location: location_1)
    end

    let!(:child_2) do
      described_class.call(repository:, parent:, kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "MyChild", location: location_2)
    end

    it "appends the source location to the existing scope" do
      expect(child_1).to be(child_2)

      expect(child_2.locations.items).to match_array([location_1, location_2])
    end

    it "updates the source locations in the repository" do
      expect(repository.find_by_fully_qualified_name("::MyModule::MyChild")).to be(child_2)
    end
  end
end