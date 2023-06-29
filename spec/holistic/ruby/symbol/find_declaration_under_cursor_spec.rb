# frozen_string_literal: true

describe ::Holistic::Ruby::Symbol::FindDeclarationUnderCursor do
  include ::SnippetParser

  let(:application) do
    parse_snippet <<~RUBY
    module MyApp
      module Example; end

      Example.call
      ::String.new
    end
    RUBY
  end

  context "when symbol does not exist" do
    it "returns :not_found" do
      cursor = ::Holistic::Document::Cursor.new("snippet.rb", 0, 0)

      result = described_class.call(application:, cursor:)

      expect(result).to eql(:not_found)
    end
  end

  context "when symbol is not a reference" do
    it "returns :symbol_is_not_reference" do
      cursor = ::Holistic::Document::Cursor.new("snippet.rb", 2, 15)

      result, data = described_class.call(application:, cursor:)

      expect(result).to eql(:symbol_is_not_reference)
      expect(data[:origin].identifier).to eql("::MyApp::Example")
    end
  end

  context "when symbol references a constant from an external lib" do
    it "returns :could_not_find_declaration" do
      cursor = ::Holistic::Document::Cursor.new("snippet.rb", 5, 9)

      result, _data = described_class.call(application:, cursor:)

      expect(result).to eql(:could_not_find_declaration)
    end
  end

  context "when symbol references a constant declared within the application" do
    it "returns :declaration_found" do
      cursor = ::Holistic::Document::Cursor.new("snippet.rb", 4, 9)

      result, data = described_class.call(application:, cursor:)

      expect(result).to eql(:declaration_found)
      expect(data[:origin].record.conclusion.dependency_identifier).to eql("::MyApp::Example")
      expect(data[:target].identifier).to eql("::MyApp::Example")
    end
  end
end
