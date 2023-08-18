# frozen_string_literal: true

describe ::Holistic::LanguageServer::Requests::TextDocument::Completion do
  include ::Support::SnippetParser
  include ::Support::LanguageServer::Factory
  include ::Support::Document::ApplyChange

  let(:source_code) do
    <<~RUBY
    module MyApp
      module Payment; end

      module Controller
        def index
          Pay # autocompletion 01
        end
      end
    end

    My # autocompletion 02
    RUBY
  end

  let(:application) { parse_snippet(source_code) }

  context "when there is no document with for the given file path" do
    it "responds with nil" do
      message = build_completion_message(file_path: "/non_existing.rb", line: 0, column: 0)

      request = ::Holistic::LanguageServer::Request.new(message:, application:)

      response = described_class.call(request)

      expect(response).to have_attributes(
        itself: ::Holistic::LanguageServer::Response::Success,
        message_id: message.id,
        result: nil
      )
    end
  end

  context "when characters under cursor does not expand to valid code" do
    it "responds with nil" do
      application.unsaved_documents.add(path: "/snippet.rb", content: ::String.new(source_code))
      
      message = build_completion_message(file_path: "/snippet.rb", line: 2, column: 0)

      request = ::Holistic::LanguageServer::Request.new(message:, application:)

      response = described_class.call(request)

      expect(response).to have_attributes(
        itself: ::Holistic::LanguageServer::Response::Success,
        message_id: message.id,
        result: nil
      )
    end
  end

  context "when there is no scope defined around the cursor" do
    it "suggests completion from the root scope" do
      application.unsaved_documents.add(path: "/snippet.rb", content: ::String.new(source_code))

      message = build_completion_message(file_path: "/snippet.rb", line: 10, column: 1)

      request = ::Holistic::LanguageServer::Request.new(message:, application:)

      response = described_class.call(request)

      expect(response).to have_attributes(
        itself: be_a(::Holistic::LanguageServer::Response::Success),
        message_id: message.id,
        result: [
          {
            label: "MyApp"
          }
        ]
      )
    end
  end

  context "when there is a scope defined around the cursor" do
    it "suggests completion from the scope" do
      application.unsaved_documents.add(path: "/snippet.rb", content: ::String.new(source_code))

      message = build_completion_message(file_path: "/snippet.rb", line: 5, column: 8)

      request = ::Holistic::LanguageServer::Request.new(message:, application:)

      response = described_class.call(request)

      expect(response).to have_attributes(
        itself: be_a(::Holistic::LanguageServer::Response::Success),
        message_id: message.id,
        result: [
          {
            label: "Payment"
          }
        ]
      )
    end
  end

  context "when the the buffer has unsaved changes" do
    it "parses the document before running completion" do
      # change module name from "Payment" to "Payments"
      document = application.unsaved_documents.add(path: "/snippet.rb", content: ::String.new(source_code))
      insert_text_on_document(document:, text: "s", line: 1, column: 16)

      message = build_completion_message(file_path: "/snippet.rb", line: 5, column: 8)

      request = ::Holistic::LanguageServer::Request.new(message:, application:)

      response = described_class.call(request)

      expect(response).to have_attributes(
        itself: be_a(::Holistic::LanguageServer::Response::Success),
        message_id: message.id,
        result: [
          {
            label: "Payments"
          }
        ]
      )
    end
  end
end
