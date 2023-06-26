# frozen_string_literal: true

module Holistic::LanguageServer
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#shutdown
  module Requests::Shutdown
    extend self

    def call(message)
      Response.in_reply_to(message).with_result(nil)
    end
  end
end
