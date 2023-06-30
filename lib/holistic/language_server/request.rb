# frozen_string_literal: true

module Holistic::LanguageServer
  Request = ::Data.define(:message, :application) do
    def respond_with(result)
      # TODO: kill `in_reply_to` abstraction in favor of this helper.
      Response.in_reply_to(message).with(result:)
    end

    def respond_with_error(code:, description:, data: nil)
      Response::Error.new(message_id: message.id, code:, message: description, data:)
    end

    def param(*keys)
      message.param(*keys)
    end
  end
end
