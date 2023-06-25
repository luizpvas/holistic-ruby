# frozen_string_literal: true

module Holistic::LanguageServer
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#initialize
  module Requests::Initialize
    extend self

    # TODO: support multiple workspace directories.

    def call(message)
      ::Holistic.logger.info("--- got initialize ---")
      ::Holistic.logger.info(message)

      root_directory = message.param("rootPath")
      name = ::File.basename(root_directory)

      application = ::Holistic::Ruby::Application::Repository.create(name:, root_directory:)

      # TODO: parse stuff in background?
    end
  end
end
