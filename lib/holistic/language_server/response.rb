# frozen_string_literal: true

module Holistic::LanguageServer
  class Response
    module Status
      OK = "ok"
      EXIT = "exit"
      NOT_FOUND = "not_fond"
    end

    def self.in_reply_to(message)
      new(message_id: message.id, status: Status::OK)
    end

    def self.not_found
      new(message_id: nil, status: Status::NOT_FOUND)
    end

    def self.exit
      new(message_id: nil, status: Status::EXIT)
    end

    attr_reader :message_id, :result, :status

    def initialize(message_id:, status:)
      @message_id = message_id
      @status = status
    end

    def with_result(result)
      self.tap { @result = result }
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
