# frozen_string_literal: true

module Holistic::LanguageServer
  module Router
    extend self

    FROM_METHOD_TO_HANDLER = {
      "initialize"              => Requests::Lifecycle::Initialize,
      "shutdown"                => Requests::Lifecycle::Shutdown,
      "exit"                    => Requests::Lifecycle::Exit,
      "textDocument/didOpen"    => Requests::TextDocument::DidOpen,
      "textDocument/didChange"  => Requests::TextDocument::DidChange,
      "textDocument/didClose"   => Requests::TextDocument::DidClose,
      "textDocument/definition" => Requests::TextDocument::GoToDefinition
    }.freeze

    def dispatch(message)
      ::Holistic.logger.info(message)

      handler = FROM_METHOD_TO_HANDLER[message.method]

      if !handler
        ::Holistic.logger.info("handler not defined for: #{message.method}")

        return Response::NotFound.new
      end

      request = Request.new(message:, application: Current.application)

      response = handler.call(request)

      ::Holistic.logger.info(response)

      response
    end
  end
end
