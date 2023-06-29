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

  it "responds with null" do
    response = described_class.call(request)

    expect(response).to have_attributes(
      itself: ::Holistic::LanguageServer::Response::Success,
      result: nil
    )
  end
end
