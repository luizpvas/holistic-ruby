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
      "textDocument/didSave"    => Requests::TextDocument::DidSave,
      "textDocument/didClose"   => Requests::TextDocument::DidClose,
      "textDocument/definition" => Requests::TextDocument::GoToDefinition
    }.freeze

    def dispatch(message)
      ::Holistic.logger.info(message)

      return respond_with_rejection_error(message) if Current.lifecycle.reject?(message.method)

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

    private

    def respond_with_rejection_error(message)
      raise "todo"
    end
  end
end
