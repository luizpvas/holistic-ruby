# frozen_string_literal: true

describe ::Holistic::LanguageServer::Requests::Lifecycle::Shutdown do
  let(:request) do
    message =
      ::Holistic::LanguageServer::Message.new({
        "method" => "shutdown",
        "jsonrpc" => "2.0",
        "id" => 3
      })

    ::Holistic::LanguageServer::Request.new(message:, application: nil)
  end

  around(:each) do |each|
    lifecycle = ::Holistic::LanguageServer::Lifecycle.new
    lifecycle.waiting_initialized_event!
    lifecycle.initialized!

    ::Holistic::LanguageServer::Current.set(lifecycle:, &each)
  end

  it "responds with null" do
    response = described_class.call(request)

    expect(response).to have_attributes(
      itself: ::Holistic::LanguageServer::Response::Success,
      result: nil
    )
  end

  it "updates lifecycle state" do
    expect(::Holistic::LanguageServer::Current.lifecycle.state).to be(:initialized)

    described_class.call(request)

    expect(::Holistic::LanguageServer::Current.lifecycle.state).to be(:shutdown)
  end
end
