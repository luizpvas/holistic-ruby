# frozen_string_literal: true

module Holistic::LanguageServer
  module Response
    extend self
    
    Success = ::Data.define(:message_id, :result) do
      def encode
        encoded_payload = {
          "jsonrpc" => Protocol::JSONRPC_VERSION,
          "id"      => message_id,
          "result"  => result
        }.to_json

        "#{Protocol::CONTENT_LENGTH_HEADER}:#{encoded_payload.bytesize}#{Protocol::END_OF_HEADER}#{encoded_payload}"
      end
    end

    Error = ::Data.define(:message_id, :code, :message, :data) do
      def encode
        encoded_payload = {
          "jsonrpc" => Protocol::JSONRPC_VERSION,
          "id" => message_id,
          "error" => {
            "code" => code,
            "message" => message,
            "data" => data
          }
        }.to_json

        "#{Protocol::CONTENT_LENGTH_HEADER}:#{encoded_payload.bytesize}#{Protocol::END_OF_HEADER}#{encoded_payload}"
      end
    end

    Exit = ::Data.define
    NotFound = ::Data.define
  end
end
