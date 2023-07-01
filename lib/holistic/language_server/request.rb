# frozen_string_literal: true

module Holistic::LanguageServer
  Request = ::Struct.new(:message, :application, :response, keyword_init: true) do
    def respond_with(result)
      self.response = Response::Success.new(message_id: message.id, result:)
    end

    def respond_with_error(code:, description: nil, data: nil)
      self.response = Response::Error.new(message_id: message.id, code:, message: description, data:)
    end

    def param(*keys)
      message.param(*keys)
    end
  end
end
