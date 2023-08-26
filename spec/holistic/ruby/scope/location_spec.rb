# frozen_string_literal: true

describe ::Holistic::Ruby::Scope::Location do
  concerning :Helpers do
    def build_document_location(file_path)
      ::Holistic::Document::Location.beginning_of_file(file_path)
    end
  end

  describe "::Collection" do
    describe "#main" do
      context "when scope only has one location" do
        let(:scope) do
          location = described_class.new(
            declaration: build_document_location("/my_app/my_class.rb"),
            body: build_document_location("/my_app/my_class.rb")
          )

          ::Holistic::Ruby::Scope::Record.new(
            kind: ::Holistic::Ruby::Scope::Kind::CLASS,
            name: "MyClass",
            parent: nil,
            location:
          )
        end

        it "returns the location" do
          expect(scope.locations.main.declaration.file.path).to eql("/my_app/my_class.rb")
        end
      end

      context "when scope has multiple locations" do
        let(:scope) do
          ::Holistic::Ruby::Scope::Record.new(
            kind: ::Holistic::Ruby::Scope::Kind::CLASS,
            name: "MyClass",
            parent: nil
          ).tap do |scope|
            scope.locations << described_class.new(declaration: build_document_location("/my_app/my_class.rb"), body: build_document_location("/my_app/my_class.rb"))
            scope.locations << described_class.new(declaration: build_document_location("/my_app/my_class/other_class.rb"), body: build_document_location("/my_app/my_class/other_class.rb"))
          end
        end

        it "returns the location matching the scope name" do
          expect(scope.locations.main.declaration.file.path).to eql("/my_app/my_class.rb")
        end
      end
    end
  end
end
