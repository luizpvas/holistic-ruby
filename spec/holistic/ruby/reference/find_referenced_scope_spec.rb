# frozen_string_literal: true

describe ::Holistic::Ruby::Reference::FindReferencedScope do
  include ::Support::SnippetParser

  let(:application) do
    parse_snippet <<~RUBY
    module MyApp
      module Example; end

      Example.call
      ::String.new
    end
    RUBY
  end

  context "when cursor is not on a reference" do
    it "returns :not_found" do
      cursor = ::Holistic::Document::Cursor.new("/snippet.rb", 0, 0)

      result = described_class.call(application:, cursor:)

      expect(result).to eql(:not_found)
    end
  end

  context "when symbol under cursor references a constant from an external lib" do
    it "returns :could_not_find_referenced_scope" do
      cursor = ::Holistic::Document::Cursor.new("/snippet.rb", 4, 9)

      result, _data = described_class.call(application:, cursor:)

      expect(result).to eql(:could_not_find_referenced_scope)
    end
  end

  context "when symbol under cursor references a constant declared within the application" do
    it "returns :referenced_scope_found" do
      cursor = ::Holistic::Document::Cursor.new("/snippet.rb", 3, 9)

      result, data = described_class.call(application:, cursor:)

      expect(result).to eql(:referenced_scope_found)
      expect(data[:reference].conclusion.dependency_identifier).to eql("::MyApp::Example")
      expect(data[:referenced_scope].fully_qualified_name).to eql("::MyApp::Example")
    end
  end
end
