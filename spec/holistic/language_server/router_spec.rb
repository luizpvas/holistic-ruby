# frozen_string_literal: true

describe ::Holistic::LanguageServer::Router do
  context "when routing 'initialize' messages" do
    let(:message) do
      ::Holistic::LanguageServer::Message.new({
        "id" => 1,
        "jsonrpc" => "2.0",
        "method" => "initialize",
        "params" => { "capabilities" => {} }
      })
    end

    it "calls the handler" do
      expect(::Holistic::LanguageServer::Requests::Initialize).to receive(:call).with(message)

      described_class.dispatch(message)
    end
  end
end