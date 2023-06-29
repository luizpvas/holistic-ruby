# frozen_string_literal: true

module Holistic::LanguageServer
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#initialize
  module Requests::Lifecycle::Initialize
    extend self

    # TODO: support multiple workspace directories.

    ParseApplicationInBackground = ->(application) do
      ::Thread.new do
        ::Holistic::Ruby::Parser::WrapParsingUnitWithProcessAtTheEnd.call(application:) do
          ::Holistic::Ruby::Parser::ParseDirectory.call(application:, directory_path: application.root_directory)
        end
      end
    end

    def call(request)
      root_directory = request.param("rootPath")
      name = ::File.basename(root_directory)

      Current.application = ::Holistic::Ruby::Application.new(name:, root_directory:)

      ParseApplicationInBackground.call(Current.application)

      request.respond_with({
        capabilities: {
          # Defines how the host (editor) should sync document changes to the language server.
          # Incremental means documents are synced by sending the full content on open.
          # After that only incremental updates to the document are sent.
          textDocumentSync: Protocol::INCREMENTAL_TEXT_DOCUMENT_SYNCHRONIZATION,

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
