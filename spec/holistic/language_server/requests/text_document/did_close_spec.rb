# frozen_string_literal: true

describe ::Holistic::LanguageServer::Requests::TextDocument::DidClose do
  concerning :Helpers do
    def apply_change_to_document!(document)
      change =
        ::Holistic::Document::Unsaved::Change.new(
          range_length: 1,
          text: "a",
          start_line: 0,
          start_column: 0,
          end_line: 0,
          end_column: 0
        )
      
      document.apply_change(change)
    end
  end

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

      expect(response).to have_attributes(
        itself: be_a(::Holistic::LanguageServer::Response::Success),
        result: nil
      )
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

      expect(response).to have_attributes(
        itself: be_a(::Holistic::LanguageServer::Response::Success),
        result: nil
      )
    end

    it "calls the parser with the original content" do
      apply_change_to_document!(unsaved_document)

      expect(described_class)
        .to receive(:process_in_background)
        .with(
          application:,
          file: have_attributes(
            itself: ::Holistic::Document::File::Fake,
            read: "CONTENT"
          )
        )

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
