# frozen_string_literal: true

describe ::Holistic::LanguageServer::Requests::TextDocument::DidClose do
  include ::Support::Document::EditOperations

  let(:application) { ::Holistic::Application.new(name: "dummy", root_directory: ".") }

  let(:file_path) { "/my_app/example.rb" }

  let(:message) do
    ::Holistic::LanguageServer::Message.new({
      "method" => "textDocument/didClose",
      "jsonrpc" => "2.0",
      "params" => {
        "textDocument" => {
          "uri"=>"file://#{file_path}"
        }
      }
    })
  end

  let!(:unsaved_document) do
    application.unsaved_documents.add(path: file_path, content: ::String.new("CONTENT"))
  end

  context "when document does not have unsaved changes" do
    it "returns an empty response" do
      request = ::Holistic::LanguageServer::Request.new(application:, message:)

      response = described_class.call(request)

      expect(response).to be_a(::Holistic::LanguageServer::Response::Drop)
    end
    
    it "deletes the document buffer from the application" do
      request = ::Holistic::LanguageServer::Request.new(application:, message:)
      described_class.call(request)

      expect(application.unsaved_documents.find(file_path)).to be_nil
    end
  end

  context "when document has unsaved changes" do
    it "returns an empty response" do
      request = ::Holistic::LanguageServer::Request.new(application:, message:)

      response = described_class.call(request)

      expect(response).to be_a(::Holistic::LanguageServer::Response::Drop)
    end

    it "calls the parser with the original content" do
      write_to_document(document: unsaved_document, text: "a", line: 0, column: 0)

      expect(::Holistic::Ruby::Parser::LiveEditing::ProcessFileChanged)
        .to receive(:call)
        .with(application:, file_path:, content: "CONTENT")

      request = ::Holistic::LanguageServer::Request.new(application:, message:)
      described_class.call(request)
    end

    it "deletes the document buffer from the application" do
      request = ::Holistic::LanguageServer::Request.new(application:, message:)
      described_class.call(request)

      expect(application.unsaved_documents.find(file_path)).to be_nil
    end
  end
end
