# frozen_string_literal: true

module Holistic::LanguageServer
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#initialize
  module Requests::Lifecycle::Initialize
    extend self

    # TODO: support multiple workspace directories.

    def call(message)
      root_directory = message.param("rootPath")
      name = ::File.basename(root_directory)

      application = ::Holistic::Ruby::Application::Repository.create(name:, root_directory:)

      # TODO: parse stuff in background?

      Response.in_reply_to(message).with(result: {
        capabilities: {
          # Defines how the host (editor) should sync document changes to the language server.
          # The value 2 means it is incremental. Documents are synced by sending the full content on open.
          # After that only incremental updates to the document are sent.
          #
          # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocumentSyncKind
          textDocumentSync: 2,

          # The server provides goto definition support.
          definitionProvider: true
        },
        serverInfo: {
          name: "Holistic Ruby",
          version: ::Holistic::VERSION
        }
      })
    end
  end
end
