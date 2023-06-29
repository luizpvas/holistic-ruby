# frozen_string_literal: true

module Holistic::LanguageServer
  Request = ::Data.define(:message, :application) do
    def respond_with(result)
      Response.in_reply_to(message).with(result:)
    end

    def param(*keys)
      message.param(*keys)
    end
  end
end
