# frozen_string_literal: true

describe ::Holistic::LanguageServer::Response do
  describe "#encode" do
    it "serializes the response as json" do
      message = ::Holistic::LanguageServer::Message.new({ "jsonrpc" => "2.0", "id" => 15 })

      response = described_class.in_reply_to(message).with(result: { "example" => "ok" })

      encoded_payload = { "jsonrpc" => "2.0", "id" => 15, "result" => { "example" => "ok" } }.to_json

      encoded_response = "Content-Length:#{encoded_payload.bytesize}\r\n\r\n#{encoded_payload}"

      expect(response.encode).to eql(encoded_response)
    end
  end
end
