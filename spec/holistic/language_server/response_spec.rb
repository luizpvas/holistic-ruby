# frozen_string_literal: true

describe ::Holistic::LanguageServer::Response do
  describe "#to_json" do
    it "serializes the response as json" do
      message = ::Holistic::LanguageServer::Message.new({ "jsonrpc" => "2.0", "id" => 15 })

      response = described_class.in_reply_to(message).with_result({ "example" => "ok" })

      expect(response.to_json).to include({
        "jsonrpc" => "2.0",
        "id" => 15,
        "result" => { "example" => "ok" }
      }.to_json)
    end
  end
end
