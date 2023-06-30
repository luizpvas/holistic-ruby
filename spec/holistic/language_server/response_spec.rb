# frozen_string_literal: true

describe ::Holistic::LanguageServer::Response do
  describe "Success" do
    describe "#encode" do
      it "serializes the response as json" do
        message = ::Holistic::LanguageServer::Message.new({ "jsonrpc" => "2.0", "id" => 15 })

        response = ::Holistic::LanguageServer::Response::Success.new(
          message_id: message.id,
          result: { "example" => "ok" }
        )

        encoded_payload = { "jsonrpc" => "2.0", "id" => 15, "result" => { "example" => "ok" } }.to_json

        encoded_response = "Content-Length:#{encoded_payload.bytesize}\r\n\r\n#{encoded_payload}"

        expect(response.encode).to eql(encoded_response)
      end
    end
  end

  describe "Error" do
    describe "#encode" do
      it "serializes the response as json" do
        response = described_class::Error.new(
          message_id: 15,
          code: -10,
          message: "something went wrong",
          data: { status: "error" }
        )

        encoded_payload = {
          "jsonrpc" => "2.0",
          "id" => 15,
          "error" => {
            "code" => -10,
            "message" => "something went wrong",
            "data" => { "status" => "error" }
          }
        }.to_json

        encoded_response = "Content-Length:#{encoded_payload.bytesize}\r\n\r\n#{encoded_payload}"

        expect(response.encode).to eql(encoded_response)
      end
    end
  end
end
