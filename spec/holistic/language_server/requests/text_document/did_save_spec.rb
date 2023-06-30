# frozen_string_literal: true

describe ::Holistic::LanguageServer::Requests::TextDocument::DidSave do
  let(:application) { ::Holistic::Application.new(name: "dummy", root_directory: ".") }

  let(:file_path) { "my_app/example.rb" }

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

  before(:each) do
    application.unsaved_documents.add(path: file_path, content: "content")
  end

  it "returns an empty response" do
    request = ::Holistic::LanguageServer::Request.new(application:, message:)

    response = described_class.call(request)

    expect(response).to have_attributes(
      itself: be_a(::Holistic::LanguageServer::Response::Success),
      result: nil
    )
  end

  it "parses unsaved changes in background" do
    expect(described_class::ProcessInBackground)
      .to receive(:call)
      .with(application:, file: be_a(::Holistic::Document::File::Fake))

    request = ::Holistic::LanguageServer::Request.new(application:, message:)
    described_class.call(request)
  end
end