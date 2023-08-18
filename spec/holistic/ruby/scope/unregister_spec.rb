# frozen_string_literal: true

describe ::Holistic::Ruby::Scope::Unregister do
  concerning :TestHelpers do
    def create_root_scope
      ::Holistic::Ruby::Scope::Record.new(kind: ::Holistic::Ruby::Scope::Kind::ROOT, name: "::", parent: nil)
    end

    def build_scope_location(file_name)
      ::Holistic::Ruby::Scope::Location.new(declaration: build_document_location(file_name), body: build_document_location(file_name))
    end

    def build_document_location(file_name)
      ::Holistic::Document::Location.beginning_of_file(file_name)
    end
  end

  context "when scope does not exist" do
    let(:repository) { ::Holistic::Ruby::Scope::Repository.new }

    it "returns :scope_not_found" do
      result = described_class.call(repository:, fully_qualified_name: "NonExisting", file_path: "/snippet.rb")

      expect(result).to be(:scope_not_found)
    end
  end

  context "when scope exists but is not defined in the specified file" do
    let(:repository) { ::Holistic::Ruby::Scope::Repository.new }

    let!(:scope) do
      ::Holistic::Ruby::Scope::Register.call(
        repository:,
        parent: create_root_scope,
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyModule",
        location: build_scope_location("/snippet.rb")
      )
    end

    it "returns :scope_not_defined_in_speciefied_file" do
      result = described_class.call(repository:, fully_qualified_name: "::MyModule", file_path: "/non_existing.rb")

      expect(result).to be(:scope_not_defined_in_speciefied_file)
    end
  end

  context "when scope exists and the only definition of it is in the specified file" do
    let(:repository) { ::Holistic::Ruby::Scope::Repository.new }

    let(:parent) { create_root_scope }

    let!(:scope) do
      ::Holistic::Ruby::Scope::Register.call(
        repository:,
        parent:,
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyModule",
        location: build_scope_location("/snippet.rb")
      )
    end

    it "detaches the scope its parent and deletes from the repository" do
      result = described_class.call(repository:, fully_qualified_name: "::MyModule", file_path: "/snippet.rb")

      expect(result).to be(:definition_unregistered)

      expect(parent.children.size).to be(0)
      expect(repository.table.size).to be(0)
    end
  end

  context "when scope exists and it is defined in multiple files" do
    let(:repository) { ::Holistic::Ruby::Scope::Repository.new }

    let(:parent) { create_root_scope }

    let(:location_1) { build_scope_location("/snippet_1.rb") }
    let(:location_2) { build_scope_location("/snippet_2.rb") }

    let!(:scope) do
      ::Holistic::Ruby::Scope::Register.call(
        repository:,
        parent:,
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyModule",
        location: location_1
      )

      ::Holistic::Ruby::Scope::Register.call(
        repository:,
        parent:,
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyModule",
        location: location_2
      )
    end

    it "removes the location for the specified path" do
      expect(scope.locations.items).to match_array([location_1, location_2])

      described_class.call(repository:, fully_qualified_name: "::MyModule", file_path: "/snippet_1.rb")

      expect(scope.locations.items).to match_array([location_2])
    end

    it "updates the repository record" do
      expect(repository.list_scopes_in_file("/snippet_1.rb")).to match_array([scope])

      described_class.call(repository:, fully_qualified_name: "::MyModule", file_path: "/snippet_1.rb")

      expect(repository.list_scopes_in_file("/snippet_1.rb")).to be_empty
    end

    it "does not detach the scope from its parent" do
      described_class.call(repository:, fully_qualified_name: "::MyModule", file_path: "/snippet_1.rb")

      expect(parent.children).to match_array([scope])
    end
  end
end
