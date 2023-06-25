# frozen_string_literal: true

module Holistic::LanguageServer
  class Response
    attr_reader :message_id, :result

    JSON_RPC_VERSION = "2.0"

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
      {
        "jsonrpc" => JSON_RPC_VERSION,
        "id"      => message_id,
        "result"  => result
      }.to_json
    end
  end
end
