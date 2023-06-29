# frozen_string_literal: true

describe ::Holistic::LanguageServer::Requests::TextDocument::GoToDefinition do
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

  around(:each) do |each|
    ::Holistic::LanguageServer::Current.set(application:, &each)
  end

  context "when symbol under cursor does not exist" do
    it "responds with null" do
      message = ::LanguageServer::Factory.build_definition_message(file_path: "snippet.rb", line: 0, column: 0)

      response = described_class.call(message)

      expect(response).to have_attributes(
        itself: ::Holistic::LanguageServer::Response::Success,
        message_id: message.id,
        result: nil
      )
    end
  end

  context "when symbol under cursor is not a reference" do
    it "responds with null" do
      message = ::LanguageServer::Factory.build_definition_message(file_path: "snippet.rb", line: 1, column: 12)

      response = described_class.call(message)

      expect(response).to have_attributes(
        itself: ::Holistic::LanguageServer::Response::Success,
        message_id: message.id,
        result: nil
      )
    end
  end

  context "when symbol under cursor is a reference to something we could not find" do
    it "responds with null" do
      message = ::LanguageServer::Factory.build_definition_message(file_path: "snippet.rb", line: 5, column: 9)

      response = described_class.call(message)

      expect(response).to have_attributes(
        itself: ::Holistic::LanguageServer::Response::Success,
        message_id: message.id,
        result: nil
      )
    end
  end

  context "when symbol under cursor is a reference to something we could find" do
    it "responds with the dependency location" do
      message = ::LanguageServer::Factory.build_definition_message(file_path: "snippet.rb", line: 4, column: 9)

      response = described_class.call(message)

      expect(response).to have_attributes(
        itself: ::Holistic::LanguageServer::Response::Success,
        message_id: message.id,
        result: [{
          "originSelectionRange" => {
            "start" => { "line" => 4, "character" => 2 },
            "end" => { "line" => 4, "character" => 9 }
          },
          "targetUri" => "file://snippet.rb",
          "targetRange" => {
            "start" => { "line" => 2, "character" => 2 },
            "end" => { "line" => 2, "character" => 21 }
          },
          "targetSelectionRange" => {
            "start" => { "line" => 2, "character" => 2 },
            "end" => { "line" => 2, "character" => 21 }
          }
        }]
      )
    end
  end
end
