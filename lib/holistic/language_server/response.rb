# frozen_string_literal: true

module Holistic::LanguageServer
  class Response
    attr_reader :message_id, :result

    JSONRPC_VERSION = "2.0"

    def self.in_reply_to(message)
      new(message_id: message.id)
    end

    def initialize(message_id:)
      @message_id = message_id
    end

    def with_result(result)
      self.tap { @result = result }
    end

    def to_json
      encoded_payload = {
        "jsonrpc" => JSONRPC_VERSION,
        "id"      => message_id,
        "result"  => result
      }.to_json

      "Content-Length: #{encoded_payload.bytesize}\r\n\r\n#{encoded_payload}"
    end
  end
end
