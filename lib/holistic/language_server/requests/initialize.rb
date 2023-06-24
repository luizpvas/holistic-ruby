# frozen_string_literal: true

module Holistic::LanguageServer
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#initialize
  module Requests::Initialize
    extend self

    def call(message)
      ::Holistic.logger.info("--- got initialize ---")
      ::Holistic.logger.info(message)
    end
  end
end
