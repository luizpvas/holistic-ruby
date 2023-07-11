# frozen_string_literal: true

describe ::Holistic::LanguageServer::Requests::TextDocument::FindReferences do
  include ::Support::SnippetParser
  include ::Support::LanguageServer::Factory
  include ::Support::Document::ApplyChange

  let(:source_code) do
    <<~RUBY
    module MyApp
      module Example1; end
      module Example2; end

      Example1.call
    end
    RUBY
  end

  let(:application) { parse_snippet(source_code) }

  context "when the word under cursor is not a scope" do
    it "reponds with null" do
      message = build_references_message(file_path: "/snippet.rb", line: 0, column: 0)

      request = ::Holistic::LanguageServer::Request.new(message:, application:)

      response = described_class.call(request)

      expect(response).to have_attributes(
        itself: ::Holistic::LanguageServer::Response::Success,
        message_id: message.id,
        result: nil
      )
    end
  end

  context "when scope under cursor has no references" do
    it "responds with an empty list" do
      message = build_references_message(file_path: "/snippet.rb", line: 2, column: 10)

      request = ::Holistic::LanguageServer::Request.new(message:, application:)

      response = described_class.call(request)

      expect(response).to have_attributes(
        itself: ::Holistic::LanguageServer::Response::Success,
        message_id: message.id,
        result: []
      )
    end
  end

  context "when scope under cursor has references" do
    it "reponds with a list of locations of the references" do
      message = build_references_message(file_path: "/snippet.rb", line: 1, column: 10)

      request = ::Holistic::LanguageServer::Request.new(message:, application:)

      response = described_class.call(request)

      expect(response).to have_attributes(
        itself: ::Holistic::LanguageServer::Response::Success,
        message_id: message.id,
        result: [
          {
            "uri" => "file:///snippet.rb",
            "range" => {
              "start" => { "line" => 4, "character" => 2 },
              "end" => { "line" => 4, "character" => 10 }
            },
          }
        ]
      )
    end
  end

  context "when cursor's document has unsaved changes" do
    it "parses the document before attempting to find references" do
      # add a new line after `module MyApp`, shifting the code down a line
      document = application.unsaved_documents.add(path: "/snippet.rb", content: ::String.new(source_code))
      insert_new_line_on_document(document:, after_line: 0)

      # Example.call is now on line 2 instead of 1
      message = build_definition_message(file_path: "/snippet.rb", line: 2, column: 10)
      request = ::Holistic::LanguageServer::Request.new(message:, application:)

      response = described_class.call(request)

      expect(response).to have_attributes(
        itself: ::Holistic::LanguageServer::Response::Success,
        message_id: message.id,
        result: [
          {
            "uri" => "file:///snippet.rb",
            "range" => {
              "start" => { "line" => 5, "character" => 2 },
              "end" => { "line" => 5, "character" => 10 }
            },
          }
        ]
      )
    end
  end
end
