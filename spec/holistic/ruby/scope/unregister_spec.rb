# frozen_string_literal: true

describe ::Holistic::Ruby::Scope::Unregister do
  concerning :TestHelpers do
    def build_scope_location(files:, file_path:)
      ::Holistic::Ruby::Scope::Location.new(
        declaration: files.build_fake_location(file_path),
        body: files.build_fake_location(file_path)
      )
    end
  end

  context "when scope does not exist" do
    let(:application) { ::Holistic::Application.new(name: "fake", root_directory: ".") }

    it "returns :scope_not_found" do
      result = described_class.call(database: application.database, fully_qualified_name: "NonExisting", file_path: "/snippet.rb")

      expect(result).to be(:scope_not_found)
    end
  end

  context "when scope exists but is not defined in the specified file" do
    let(:application) { ::Holistic::Application.new(name: "fake", root_directory: ".") }

    let!(:scope) do
      ::Holistic::Ruby::Scope::Register.call(
        database: application.database,
        parent: application.scopes.root,
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyModule",
        location: build_scope_location(files: application.files, file_path: "/snippet.rb")
      )
    end

    it "returns :scope_not_defined_in_speciefied_file" do
      result = described_class.call(database: application.database, fully_qualified_name: "::MyModule", file_path: "/non_existing.rb")

      expect(result).to be(:scope_not_defined_in_speciefied_file)
    end
  end

  context "when scope exists and the only definition of it is in the specified file" do
    let(:application) { ::Holistic::Application.new(name: "fake", root_directory: ".") }

    let(:parent) { application.scopes.root }

    let(:location) { build_scope_location(files: application.files, file_path: "/snippet.rb") }

    let!(:scope) do
      ::Holistic::Ruby::Scope::Register.call(
        database: application.database,
        parent: application.scopes.root,
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyModule",
        location:
      )
    end

    it "detaches the scope its parent and deletes the node from the database" do
      expect(parent.children).to eql([scope])

      result = described_class.call(database: application.database, fully_qualified_name: "::MyModule", file_path: "/snippet.rb")

      expect(result).to be(:definition_unregistered)

      expect(parent.children).to be_empty
      expect(application.database.find("::MyModule")).to be_nil
    end

    it "disconnects the scope from the file" do
      expect(location.declaration.file.has_many(:defines_scopes)).to eql([scope])

      result = described_class.call(database: application.database, fully_qualified_name: "::MyModule", file_path: "/snippet.rb")

      expect(location.declaration.file.has_many(:defines_scopes)).to be_empty
    end
  end

  context "when scope exists and it is defined in multiple files" do
    let(:application) { ::Holistic::Application.new(name: "fake", root_directory: ".") }

    let(:parent) { application.scopes.root }

    let(:location_1) { build_scope_location(files: application.files, file_path: "/snippet_1.rb") }
    let(:location_2) { build_scope_location(files: application.files, file_path: "/snippet_2.rb") }

    let!(:scope) do
      # first call to register
      ::Holistic::Ruby::Scope::Register.call(
        database: application.database,
        parent:,
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyModule",
        location: location_1
      )

      # second call to add location
      ::Holistic::Ruby::Scope::Register.call(
        database: application.database,
        parent:,
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyModule",
        location: location_2
      )
    end

    it "removes the location for the specified path" do
      expect(scope.locations.items).to match_array([location_1, location_2])

      described_class.call(database: application.database, fully_qualified_name: "::MyModule", file_path: "/snippet_1.rb")

      expect(scope.locations.items).to match_array([location_2])
    end

    it "updates the relations between scope and file in the database" do
      expect(application.scopes.list_scopes_in_file("/snippet_1.rb")).to match_array([scope])

      described_class.call(database: application.database, fully_qualified_name: "::MyModule", file_path: "/snippet_1.rb")

      expect(application.scopes.list_scopes_in_file("/snippet_1.rb")).to be_empty
    end

    it "does not detach the scope from its parent" do
      described_class.call(database: application.database, fully_qualified_name: "::MyModule", file_path: "/snippet_1.rb")

      expect(parent.children).to match_array([scope])
    end
  end
end
