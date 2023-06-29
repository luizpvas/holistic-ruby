# frozen_string_literal: true

describe ::Holistic::LanguageServer::Requests::Lifecycle::Initialize do
  let(:request) do
    message =
      ::Holistic::LanguageServer::Message.new(
        ::JSON.parse(::File.read("spec/fixtures/language_server_initialize_message.json"))
      )

    ::Holistic::LanguageServer::Request.new(message:, application: nil)
  end

  after(:each) do
    ::Holistic::LanguageServer::Current.application = nil
  end

  it "registers an application on the root directory" do
    expect(::Holistic::LanguageServer::Current.application).to be_nil

    described_class.call(request)

    expect(::Holistic::LanguageServer::Current.application).to have_attributes(
      name: "holistic",
      root_directory: "/home/luiz.vasconcellos/Projects/holistic"
    )
  end

  it "returns a response with the Holistic capabilities" do
    response = described_class.call(request)

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
