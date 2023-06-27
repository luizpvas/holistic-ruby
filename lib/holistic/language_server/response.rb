# frozen_string_literal: true

module Holistic::LanguageServer
  class Response
    attr_reader :message_id, :result

    EXIT_MESSAGE_ID = -1

    def self.in_reply_to(message)
      new(message_id: message.id)
    end

    def self.exit
      new(message_id: EXIT_MESSAGE_ID)
    end

    def initialize(message_id:)
      @message_id = message_id
    end

    def with_result(result)
      self.tap { @result = result }
    end

    def exit?
      message_id == EXIT_MESSAGE_ID
    end

    def encode
      encoded_payload = {
        "jsonrpc" => Protocol::JSONRPC_VERSION,
        "id"      => message_id,
        "result"  => result
      }.to_json

      "#{Protocol::CONTENT_LENGTH_HEADER}:#{encoded_payload.bytesize}#{Protocol::END_OF_HEADER}#{encoded_payload}"
    end
  end
end
