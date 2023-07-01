# frozen_string_literal: true

describe ::Holistic::LanguageServer::Requests::Lifecycle::Initialized do
  let(:request) do
    message =
      ::Holistic::LanguageServer::Message.new({
        "jsonrpc" => "2.0",
        "method" => "initialized"
      })

    ::Holistic::LanguageServer::Request.new(message:, application: nil)
  end

  around(:each) do |each|
    lifecycle = ::Holistic::LanguageServer::Lifecycle.new
    lifecycle.waiting_initialized_event!

    ::Holistic::LanguageServer::Current.set(lifecycle:, &each)
  end

  it "reponds with nil" do
    response = described_class.call(request)

    expect(response).to have_attributes(
      itself: ::Holistic::LanguageServer::Response::Success,
      result: nil
    )
  end

  it "updates the lifecycle state to :initialized" do
    expect(::Holistic::LanguageServer::Current.lifecycle.state).to be(:waiting_initialized_event)

    described_class.call(request)

    expect(::Holistic::LanguageServer::Current.lifecycle.state).to be(:initialized)
  end
end
