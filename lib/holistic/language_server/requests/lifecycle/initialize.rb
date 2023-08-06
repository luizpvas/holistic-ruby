# frozen_string_literal: true

module Holistic::LanguageServer
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#initialize
  module Requests::Lifecycle::Initialize
    extend self

    # TODO: support multiple workspace directories.

    def call(request)
      application = create_application(request)

      advance_lifecycle_state

      parse_application_in_background(application)

      respond_with_holistic_capabilities(request)
    end

    private

    def create_application(request)
      root_directory = request.param("rootPath")
      name = ::File.basename(root_directory)

      Current.application = ::Holistic::Application.new(name:, root_directory:)

      ::Holistic::Extensions::Ruby::Stdlib.register(Current.application)

      Current.application
    end

    def advance_lifecycle_state
      Current.lifecycle.waiting_initialized_event!
    end

    def parse_application_in_background(application)
      ::Holistic::BackgroundProcess.run do
        ::Holistic::Ruby::Parser::ParseDirectory.call(application:, directory_path: application.root_directory)

        ::Holistic::Ruby::TypeInference::SolvePendingReferences.call(application:)
      end
    end

    def respond_with_holistic_capabilities(request)
      request.respond_with({
        capabilities: {
          # Defines how the host (editor) should sync document changes to the language server.
          # Incremental means documents are synced by sending the full content on open.
          # After that only incremental updates to the document are sent.
          textDocumentSync: Protocol::INCREMENTAL_TEXT_DOCUMENT_SYNCHRONIZATION,

          # The server provides goto definition support.
          definitionProvider: true,

          # The server provides find references support.
          referencesProvider: true
        },
        serverInfo: {
          name: "Holistic Ruby",
          version: ::Holistic::VERSION
        }
      })
    end
  end
end
