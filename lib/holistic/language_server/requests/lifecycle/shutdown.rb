# frozen_string_literal: true

module Holistic::LanguageServer
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#shutdown
  module Requests::Lifecycle::Shutdown
    extend self

    def call(request)
      request.respond_with(nil)
    end
  end
end
