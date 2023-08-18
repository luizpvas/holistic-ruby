# frozen_string_literal: true

describe ::Holistic::LanguageServer::Requests::Lifecycle::Initialize do
  include ::Support::LanguageServer::Factory

  let(:request) do
    message = build_initialize_message(root_directory: "/my_app")

    ::Holistic::LanguageServer::Request.new(message:, application: nil)
  end

  after(:each) do
    ::Holistic::LanguageServer::Current.application = nil
  end

  around(:each) do |each|
    lifecycle = ::Holistic::LanguageServer::Lifecycle.new

    ::Holistic::LanguageServer::Current.set(lifecycle:, &each)
  end

  it "returns a response with the Holistic capabilities" do
    response = described_class.call(request)

    expect(response).to have_attributes(
      itself: ::Holistic::LanguageServer::Response::Success,
      result: {
        capabilities: {
          textDocumentSync: 2,
          definitionProvider: true,
          referencesProvider: true,
          completionProvider: {
            triggerCharacters: ["::", "."]
          }
        },
        serverInfo: {
          name: "Holistic Ruby",
          version: ::Holistic::VERSION
        }
      }
    )
  end

  it "updates the lifecycle state" do
    expect(::Holistic::LanguageServer::Current.lifecycle.state).to be(:waiting_initialize_event)

    described_class.call(request)

    expect(::Holistic::LanguageServer::Current.lifecycle.state).to be(:waiting_initialized_event)
  end

  it "registers an application on the root directory" do
    expect(::Holistic::LanguageServer::Current.application).to be_nil

    described_class.call(request)

    expect(::Holistic::LanguageServer::Current.application).to have_attributes(
      name: "my_app",
      root_directory: "/my_app"
    )
  end
end
