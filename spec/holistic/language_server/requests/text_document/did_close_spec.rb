# frozen_string_literal: true

describe ::Holistic::LanguageServer::Requests::TextDocument::DidClose do
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

  let(:application) { ::Holistic::Application.new(name: "dummy", root_directory: ".") }

  it "responds with nil" do
    request = ::Holistic::LanguageServer::Request.new(application:, message:)

    response = described_class.call(request)

    expect(response).to have_attributes(
      itself: be_a(::Holistic::LanguageServer::Response::Success),
      result: nil
    )
  end
  
  it "deletes the document buffer from the application" do
    application.unsaved_documents.add(path: file_path, content: "CONTENT")

    request = ::Holistic::LanguageServer::Request.new(application:, message:)
    described_class.call(request)

    expect(application.unsaved_documents.find(file_path)).to be_nil
  end
end