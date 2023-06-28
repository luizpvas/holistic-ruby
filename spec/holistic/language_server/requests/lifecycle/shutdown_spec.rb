# frozen_string_literal: true

describe ::Holistic::LanguageServer::Requests::Lifecycle::Shutdown do
  let(:message) do
    ::Holistic::LanguageServer::Message.new({
      "method" => "shutdown",
      "jsonrpc" => "2.0",
      "id" => 3
    })
  end

  it "responds with null" do
    response = described_class.call(message)

    expect(response).to have_attributes(
      itself: ::Holistic::LanguageServer::Response::Success,
      result: nil
    )
  end
end
