# frozen_string_literal: true

describe ::Holistic::Ruby::Scope::Store do
  context "when a scope with the same name DOES NOT EXIST in the parent scope" do
    let(:application) { ::Holistic::Application.new(name: "fake", root_directory: ".") }
    let(:parent)      { application.scopes.root }

    let(:child_1_location) do
      ::Holistic::Ruby::Scope::Location.new(
        declaration: application.files.build_fake_location("app_1.rb"),
        body: application.files.build_fake_location("app_1.rb")
      )
    end

    let!(:child_1) do
      described_class.call(
        database: application.database,
        parent:,
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyChild1",
        location: child_1_location
      )
    end

    let(:child_2_location) do
      ::Holistic::Ruby::Scope::Location.new(
        declaration: application.files.build_fake_location("app_2.rb"),
        body: application.files.build_fake_location("app_2.rb")
      )
    end

    let!(:child_2) do
      described_class.call(
        database: application.database,
        parent:,
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyChild2",
        location: child_2_location
      )
    end

    it "adds new children in the parent scope" do
      expect(parent.children).to match_array([child_1, child_2])

      expect(child_1.parent).to be(parent)
      expect(child_1.attributes).to match({
        fully_qualified_name: "::MyChild1",
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyChild1",
        locations: be_a(::Holistic::Ruby::Scope::Location::Collection)
      })

      expect(child_1.locations.items).to match_array([
        child_1_location
      ])

      expect(child_2.parent).to be(parent)
      expect(child_2.attributes).to match({
        fully_qualified_name: "::MyChild2",
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyChild2",
        locations: be_a(::Holistic::Ruby::Scope::Location::Collection)
      })

      expect(child_2.locations.items).to match_array([
        child_2_location
      ])
    end

    it "inserts the scope in the database" do
      expect(application.database.find("::MyChild1")).to be(child_1)
      expect(application.database.find("::MyChild2")).to be(child_2)
    end

    it "connects the scope to the file" do
      child_1_file = child_1.locations.main.declaration.file
      expect(child_1_file.defines_scopes).to match_array([child_1])

      child_2_file = child_2.locations.main.declaration.file
      expect(child_2_file.defines_scopes).to match_array([child_2])
    end
  end

  context "when a scope with the same name EXISTS in the parent scope" do
    let(:application) { ::Holistic::Application.new(name: "fake", root_directory: ".") }
    let(:parent)      { application.scopes.root }

    let(:location_1) { ::Holistic::Ruby::Scope::Location.new(declaration: application.files.build_fake_location("app_1.rb"), body: application.files.build_fake_location("app_1.rb")) }
    let(:location_2) { ::Holistic::Ruby::Scope::Location.new(declaration: application.files.build_fake_location("app_2.rb"), body: application.files.build_fake_location("app_2.rb")) }

    let!(:child_1) do
      described_class.call(
        database: application.database,
        parent:,
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyChild",
        location: location_1
      )
    end

    let!(:child_2) do
      described_class.call(
        database: application.database,
        parent:,
        kind: ::Holistic::Ruby::Scope::Kind::MODULE,
        name: "MyChild",
        location: location_2
      )
    end

    it "does not create a new scope" do
      expect(child_1).to be(child_2)
    end

    it "appends the source location to the existing scope" do
      expect(child_2.locations.items).to match_array([location_1, location_2])
    end

    it "connects the scope to the new location's file" do
      expect(location_1.declaration.file.defines_scopes).to match_array([child_1])
      expect(location_2.declaration.file.defines_scopes).to match_array([child_1])

      expect(
        child_1.locations.items.map { _1.declaration.file }
      ).to match_array([location_1.declaration.file, location_2.declaration.file])
    end
  end
end