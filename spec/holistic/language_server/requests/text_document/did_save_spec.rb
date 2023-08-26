# frozen_string_literal: true

describe ::Holistic::LanguageServer::Requests::TextDocument::DidSave do
  include ::Support::Document::ApplyChange

  let(:application) { ::Holistic::Application.new(name: "dummy", root_directory: ".") }

  let(:file_path) { "/my_app/example.rb" }

  let(:message) do
    ::Holistic::LanguageServer::Message.new({
      "method" => "textDocument/didSave",
      "jsonrpc" => "2.0",
      "params" => {
        "textDocument" => {
          "uri"=>"file://#{file_path}"
        }
      }
    })
  end

  context "when document exists in the :unsaved_documents collection" do
    before(:each) do
      application.unsaved_documents.add(path: file_path, content: ::String.new("content"))
    end

    it "returns an empty response" do
      request = ::Holistic::LanguageServer::Request.new(application:, message:)

      response = described_class.call(request)

      expect(response).to have_attributes(
        itself: be_a(::Holistic::LanguageServer::Response::Success),
        result: nil
      )
    end

    it "marks the document as saved" do
      unsaved_document = application.unsaved_documents.find(file_path)

      insert_text_on_document(document: unsaved_document, text: "a", line: 0, column: 0)

      request = ::Holistic::LanguageServer::Request.new(application:, message:)
      response = described_class.call(request)

      expect(unsaved_document.has_unsaved_changes?).to be(false)
    end

    it "parses unsaved changes in background" do
      expect(described_class)
        .to receive(:process_in_background)
        .with(application:, file: be_a(::Holistic::Document::File::Record))

      request = ::Holistic::LanguageServer::Request.new(application:, message:)
      described_class.call(request)
    end
  end

  context "when document does not exist in the :unsaved_documents collection" do
    it "returns an error response" do
      request = ::Holistic::LanguageServer::Request.new(application:, message:)

      response = described_class.call(request)

      expect(response).to have_attributes(
        itself: be_a(::Holistic::LanguageServer::Response::Error),
        code: ::Holistic::LanguageServer::Protocol::REQUEST_FAILED_ERROR_CODE,
        message: "could not find document #{file_path} in the unsaved documents list",
        data: nil
      )
    end
  end
end