# frozen_string_literal: true

describe ::Holistic::Ruby::Scope::Register do
  concerning :TestHelpers do
    def create_root_scope
      ::Holistic::Ruby::Scope::Record.new(kind: ::Holistic::Ruby::Scope::Kind::ROOT, name: "::", parent: nil)
    end

    def build_document_location
      ::Holistic::Document::Location.beginning_of_file("app.rb")
    end
  end

  context "when a scope with the same name DOES NOT EXIST in the parent scope" do
    let(:files) { ::Holistic::Document::File::Repository.new }
    let(:repository) { ::Holistic::Ruby::Scope::Repository.new(files:) }

    let(:parent) do
      ::Holistic::Ruby::Scope::Record.new(
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyModule",
        parent: create_root_scope
      )
    end

    let(:child_1_location) do
      ::Holistic::Ruby::Scope::Location.new(declaration: build_document_location, body: build_document_location)
    end

    let!(:child_1) do
      described_class.call(repository:, parent:, kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "MyChild1", location: child_1_location)
    end

    let(:child_2_location) do
      ::Holistic::Ruby::Scope::Location.new(declaration: build_document_location, body: build_document_location)
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

    it "connects the scope to the file" do
      child_1_file = child_1.locations.main.declaration.file
      expect(child_1_file.scopes.to_a).to eql([child_1])

      child_2_file = child_2.locations.main.declaration.file
      expect(child_2_file.scopes.to_a).to eql([child_2])
    end
  end

  context "when a scope with the same name EXISTS in the parent scope" do
    let(:files) { ::Holistic::Document::File::Repository.new }
    let(:repository) { ::Holistic::Ruby::Scope::Repository.new(files:) }

    let(:parent) do
      ::Holistic::Ruby::Scope::Record.new(
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyModule",
        parent: create_root_scope
      )
    end

    let(:location_1) { ::Holistic::Ruby::Scope::Location.new(declaration: build_document_location, body: build_document_location) }
    let(:location_2) { ::Holistic::Ruby::Scope::Location.new(declaration: build_document_location, body: build_document_location) }

    let!(:child_1) do
      described_class.call(repository:, parent:, kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "MyChild", location: location_1)
    end

    let!(:child_2) do
      described_class.call(repository:, parent:, kind: ::Holistic::Ruby::Scope::Kind::MODULE, name: "MyChild", location: location_2)
    end

    it "does not create a new scope" do
      expect(child_1).to be(child_2)
    end

    it "appends the source location to the existing scope" do
      expect(child_2.locations.items).to match_array([location_1, location_2])
    end

    it "connects the scope to the new location's file" do
      expect(location_1.declaration.file.scopes.to_a).to eql([child_1])
      expect(location_2.declaration.file.scopes.to_a).to eql([child_1])

      expect(
        child_1.locations.items.map { _1.declaration.file }
      ).to eql([location_1.declaration.file, location_2.declaration.file])
    end
  end
end