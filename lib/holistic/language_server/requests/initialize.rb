# frozen_string_literal: true

module Holistic::LanguageServer
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#initialize
  module Requests::Initialize
    extend self

    def call(message)
      ::Holistic.logger.info("--- got initialize ---")
      ::Holistic.logger.info(message)

      root_directory = message.param("rootPath")
      application = ::Holistic::Ruby::Application::Repository.create(name: "app", root_directory:)

      # TODO: parse stuff in background?
    end
  end
end
