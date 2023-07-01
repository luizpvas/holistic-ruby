# frozen_string_literal: true

module Holistic::LanguageServer
  Request = ::Data.define(:message, :application) do
    def respond_with(result)
      Response::Success.new(message_id: message.id, result:)
    end

    def respond_with_error(code:, description: nil, data: nil)
      Response::Error.new(message_id: message.id, code:, message: description, data:)
    end

    def param(*keys)
      message.param(*keys)
    end
  end
end
