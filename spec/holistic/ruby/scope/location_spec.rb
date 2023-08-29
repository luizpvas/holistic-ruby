# frozen_string_literal: true

describe ::Holistic::Ruby::Scope::Location do
  concerning :Helpers do
    def build_document_location(file_path)
      database = ::Holistic::Database::Table.new
      files = ::Holistic::Document::File::Repository.new(database:)

      files.build_fake_location(file_path)
    end
  end

  describe "::Collection" do
    describe "#main" do
      context "when scope only has one location" do
        it "returns the only location" do
          locations = described_class::Collection.new("MyClass")

          locations << described_class.new(
            declaration: build_document_location("/my_app/my_class.rb"),
            body: build_document_location("/my_app/my_class.rb")
          )

          expect(locations.main.declaration.file.attr(:path)).to eql("/my_app/my_class.rb")
        end
      end

      context "when scope has multiple locations" do
        it "returns the location matching the scope name" do
          locations = described_class::Collection.new("MyClass")

          locations << described_class.new(
            declaration: build_document_location("/my_app/my_class.rb"),
            body: build_document_location("/my_app/my_class.rb")
          )

          locations << described_class.new(
            declaration: build_document_location("/my_app/my_class/other_class.rb"),
            body: build_document_location("/my_app/my_class/other_class.rb")
          )

          expect(locations.main.declaration.file.attr(:path)).to eql("/my_app/my_class.rb")
        end
      end
    end
  end
end
