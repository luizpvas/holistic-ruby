# frozen_string_literal: true

describe ::Holistic::Ruby::Symbol::FindDefinition do
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

  context "when symbol under cursor does not exist" do
    it "returns :not_found" do
      cursor = ::Holistic::Document::Cursor.new("/snippet.rb", 0, 0)

      result = described_class.call(application:, cursor:)

      expect(result).to eql(:not_found)
    end
  end

  context "when symbol under cursor is not a reference" do
    it "returns :origin_is_not_a_reference" do
      cursor = ::Holistic::Document::Cursor.new("/snippet.rb", 1, 15)

      result, data = described_class.call(application:, cursor:)

      expect(result).to eql(:origin_is_not_a_reference)
      expect(data[:origin].identifier).to eql("::MyApp::Example")
    end
  end

  context "when symbol under cursor references a constant from an external lib" do
    it "returns :could_not_find_definition" do
      cursor = ::Holistic::Document::Cursor.new("/snippet.rb", 4, 9)

      result, _data = described_class.call(application:, cursor:)

      expect(result).to eql(:could_not_find_definition)
    end
  end

  context "when symbol under cursor references a constant declared within the application" do
    it "returns :definition_found" do
      cursor = ::Holistic::Document::Cursor.new("/snippet.rb", 3, 9)

      result, data = described_class.call(application:, cursor:)

      expect(result).to eql(:definition_found)
      expect(data[:origin].record.conclusion.dependency_identifier).to eql("::MyApp::Example")
      expect(data[:target].identifier).to eql("::MyApp::Example")
    end
  end
end
