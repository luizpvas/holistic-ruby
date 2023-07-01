# frozen_string_literal: true

describe ::Holistic::LanguageServer::Requests::TextDocument::GoToDefinition do
  include ::Support::SnippetParser
  include ::Support::LanguageServer::Factory
  include ::Support::Document::ApplyChange

  let(:source_code) do
    <<~RUBY
    module MyApp
      module Example; end

      Example.call
      ::String.new
    end
    RUBY
  end

  let(:application) { parse_snippet(source_code) }

  context "when symbol under cursor does not exist" do
    it "responds with null" do
      message = build_definition_message(file_path: "/snippet.rb", line: 0, column: 0)

      request = ::Holistic::LanguageServer::Request.new(message:, application:)

      response = described_class.call(request)

      expect(response).to have_attributes(
        itself: ::Holistic::LanguageServer::Response::Success,
        message_id: message.id,
        result: nil
      )
    end
  end

  context "when symbol under cursor is not a reference" do
    it "responds with null" do
      message = build_definition_message(file_path: "/snippet.rb", line: 0, column: 12)

      request = ::Holistic::LanguageServer::Request.new(message:, application:)

      response = described_class.call(request)

      expect(response).to have_attributes(
        itself: ::Holistic::LanguageServer::Response::Success,
        message_id: message.id,
        result: nil
      )
    end
  end

  context "when symbol under cursor is a reference to something we could not find" do
    it "responds with null" do
      message = build_definition_message(file_path: "/snippet.rb", line: 4, column: 9)

      request = ::Holistic::LanguageServer::Request.new(message:, application:)

      response = described_class.call(request)

      expect(response).to have_attributes(
        itself: ::Holistic::LanguageServer::Response::Success,
        message_id: message.id,
        result: nil
      )
    end
  end

  context "when symbol under cursor is a reference to something we could find" do
    it "responds with the dependency location" do
      message = build_definition_message(file_path: "/snippet.rb", line: 3, column: 9)

      request = ::Holistic::LanguageServer::Request.new(message:, application:)

      response = described_class.call(request)

      expect(response).to have_attributes(
        itself: ::Holistic::LanguageServer::Response::Success,
        message_id: message.id,
        result: [{
          "originSelectionRange" => {
            "start" => { "line" => 3, "character" => 2 },
            "end" => { "line" => 3, "character" => 9 }
          },
          "targetUri" => "file:///snippet.rb",
          "targetRange" => {
            "start" => { "line" => 1, "character" => 2 },
            "end" => { "line" => 1, "character" => 21 }
          },
          "targetSelectionRange" => {
            "start" => { "line" => 1, "character" => 2 },
            "end" => { "line" => 1, "character" => 21 }
          }
        }]
      )
    end
  end

  context "when document has unsaved changes" do
    it "parses the document before finding definition" do
      # add a new line after `module Example; end`, shifting the references down a line
      document = application.unsaved_documents.add(path: "/snippet.rb", content: ::String.new(source_code))
      insert_new_line_on_document(document:, after_line: 1)

      # Example.call is now on line 4 instead of 3
      message = build_definition_message(file_path: "/snippet.rb", line: 4, column: 9)
      request = ::Holistic::LanguageServer::Request.new(message:, application:)

      response = described_class.call(request)

      expect(response).to have_attributes(
        itself: ::Holistic::LanguageServer::Response::Success,
        message_id: message.id,
        result: [{
          "originSelectionRange" => {
            "start" => { "line" => 4, "character" => 2 },
            "end" => { "line" => 4, "character" => 9 }
          },
          "targetUri" => "file:///snippet.rb",
          "targetRange" => {
            "start" => { "line" => 1, "character" => 2 },
            "end" => { "line" => 1, "character" => 21 }
          },
          "targetSelectionRange" => {
            "start" => { "line" => 1, "character" => 2 },
            "end" => { "line" => 1, "character" => 21 }
          }
        }]
      )
    end
  end
end
