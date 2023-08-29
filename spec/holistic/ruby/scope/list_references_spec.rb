# frozen_string_literal: true

describe ::Holistic::Ruby::Scope::ListReferences do
  include ::Support::SnippetParser

  let(:application) do
    parse_snippet <<~RUBY
    module MyApp
      module Example
        module Perform; end
      end

      module Child
        Example::Perform.call
      end
    end
    RUBY
  end

  context "when there is no scope defined under cursor" do
    it "returns :not_found" do
      cursor = ::Holistic::Document::Cursor.new(file_path: "/snippet.rb", line: 0, column: 0)

      result = described_class.call(application:, cursor:)

      expect(result).to be(:not_found)
    end
  end

  context "when scope under cursor has no references" do
    it "returns an empty list" do
      cursor = ::Holistic::Document::Cursor.new(file_path: "/snippet.rb", line: 5, column: 10)

      result, data = described_class.call(application:, cursor:)

      expect(result).to be(:references_listed)
      expect(data[:references]).to be_empty
    end
  end

  context "when scope under cursor has references" do
    it "returns the references" do
      cursor = ::Holistic::Document::Cursor.new(file_path: "/snippet.rb", line: 2, column: 12)

      result, data = described_class.call(application:, cursor:)

      expect(result).to be(:references_listed)

      expect(data[:references]).to match_array([
        application.references.find_reference_to("Example::Perform")
      ])
    end
  end

  context "when the children of scope under cursor has references" do
    it "returns the references" do
      cursor = ::Holistic::Document::Cursor.new(file_path: "/snippet.rb", line: 1, column: 10)

      result, data = described_class.call(application:, cursor:)

      expect(result).to be(:references_listed)

      expect(data[:references]).to match_array([
        application.references.find_reference_to("Example::Perform")
      ])
    end
  end

  context "when scope under cursor is referenced by multiple files" do
    let(:application) do
      parse_snippet_collection do |files|
        files.add "/my_app/example.rb", <<~RUBY
        module MyApp
          module Example; end
        end
        RUBY

        files.add "/spec/example_spec.rb", <<~RUBY
        describe MyApp::Example do; end
        RUBY

        files.add "/my_app/reference.rb", <<~RUBY
        module MyApp
          Example.call
        end
        RUBY
      end
    end

    it "returns the references sorted by relevance" do
      cursor = ::Holistic::Document::Cursor.new(file_path: "/my_app/example.rb", line: 1, column: 10)

      result, data = described_class.call(application:, cursor:)

      expect(result).to be(:references_listed)

      references_file_paths = data[:references].map { _1.location.file.attr(:path) }

      expect(references_file_paths).to eql([
        "/my_app/reference.rb",
        "/spec/example_spec.rb"
      ])
    end
  end
end
