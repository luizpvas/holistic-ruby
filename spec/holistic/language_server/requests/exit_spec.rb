# frozen_string_literal: true

describe ::Holistic::LanguageServer::Requests::Exit do
  let(:message) do
    ::Holistic::LanguageServer::Message.new({ "jsonrpc" => "2.0", "method" => "exit" })
  end

  it "returns an exit response" do
    response = described_class.call(message)

    expect(response).to have_attributes(
      itself: ::Holistic::LanguageServer::Response,
      result: nil,
      exit?: true
    )
  end
end
