# frozen_string_literal: true

describe ::Holistic::LanguageServer::Requests::Initialize do
  let(:message) do
    ::Holistic::LanguageServer::Message.new(::JSON.parse(::File.read("spec/fixtures/language_server_initialize_message.json")))
  end

  after do
    ::Holistic::Ruby::Application::Repository.delete_all
  end

  it "registers an application on the root directory" do
    expect { described_class.call(message) }
      .to change { ::Holistic::Ruby::Application::Repository.list_all.size }.by(1)

    expect(::Holistic::Ruby::Application::Repository.find("holistic")).to have_attributes(
      name: "holistic",
      root_directory: "/home/luiz.vasconcellos/Projects/holistic"
    )
  end

  it "returns a response with the Holistic capabilities" do
    response = described_class.call(message)

    expect(response).to have_attributes(
      itself: ::Holistic::LanguageServer::Response::Success,
      result: {
        capabilities: {
          textDocumentSync: 2,
          definitionProvider: true
        },
        serverInfo: {
          name: "Holistic Ruby",
          version: ::Holistic::VERSION
        }
      }
    )
  end
end
