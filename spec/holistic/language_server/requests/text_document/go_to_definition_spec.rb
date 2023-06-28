# frozen_string_literal: true

require_relative "support/message_builder"

describe ::Holistic::LanguageServer::Requests::TextDocument::GoToDefinition do
  include ::SnippetParser
  include ::MessageBuilder

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
      cursor = ::Holistic::Document::Cursor.new("snippet.rb", 0, 0)

      message = build_definition_message_for(cursor:)

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
      cursor = ::Holistic::Document::Cursor.new("snippet.rb", 1, 12)

      message = build_definition_message_for(cursor:)

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
      cursor = ::Holistic::Document::Cursor.new("snippet.rb", 5, 9)

      message = build_definition_message_for(cursor:)

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
      cursor = ::Holistic::Document::Cursor.new("snippet.rb", 4, 9)

      message = build_definition_message_for(cursor:)

      response = described_class.call(message)

      expect(response).to have_attributes(
        itself: ::Holistic::LanguageServer::Response::Success,
        message_id: message.id,
        result: nil
      )
    end
  end
end
