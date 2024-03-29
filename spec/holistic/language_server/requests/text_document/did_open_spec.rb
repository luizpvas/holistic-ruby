# frozen_string_literal: true

describe ::Holistic::LanguageServer::Requests::TextDocument::DidOpen do
  let(:content) do
    "# frozen_string_literal: true\n\nmodule Holistic\n  VERSION = \"0.1.0\"\nend\n"
  end

  let(:message) do
    ::Holistic::LanguageServer::Message.new({
      "method" => "textDocument/didOpen",
      "jsonrpc" => "2.0",
      "params" => {
        "textDocument" => {
          "uri" => "file:///home/luiz.vasconcellos/Projects/holistic/lib/holistic/version.rb",
          "languageId" => "ruby",
          "text" => content,
          "version" => 0
        }
      }
    })
  end

  let(:application) { ::Holistic::Application.new(name: "dummy", root_directory: ".") }

  it "reponds with nil" do
    request = ::Holistic::LanguageServer::Request.new(application:, message:)

    response = described_class.call(request)

    expect(response).to be_a(::Holistic::LanguageServer::Response::Drop)
  end
  
  it "registers a file and adds a document buffer to the application" do
    request = ::Holistic::LanguageServer::Request.new(application:, message:)

    described_class.call(request)

    document = application.unsaved_documents.find("/home/luiz.vasconcellos/Projects/holistic/lib/holistic/version.rb")
    expect(document.content).to eql(content)

    file = application.files.find("/home/luiz.vasconcellos/Projects/holistic/lib/holistic/version.rb")
    expect(file.path).to eql("/home/luiz.vasconcellos/Projects/holistic/lib/holistic/version.rb")
  end
end
