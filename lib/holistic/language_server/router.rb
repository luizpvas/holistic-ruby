# frozen_string_literal: true

module Holistic::LanguageServer
  module Router
    extend self

    ROUTES = {
      "initialize"              => Requests::Lifecycle::Initialize,
      "initialized"             => Requests::Lifecycle::Initialized,
      "shutdown"                => Requests::Lifecycle::Shutdown,
      "exit"                    => Requests::Lifecycle::Exit,
      "textDocument/didOpen"    => Requests::TextDocument::DidOpen,
      "textDocument/didChange"  => Requests::TextDocument::DidChange,
      "textDocument/didSave"    => Requests::TextDocument::DidSave,
      "textDocument/didClose"   => Requests::TextDocument::DidClose,
      "textDocument/definition" => Requests::TextDocument::GoToDefinition,
      "textDocument/references" => Requests::TextDocument::FindReferences
    }.freeze

    def dispatch(message)
      request = Request.new(message:, application: Current.application)

      ::ActiveSupport::Notifications.instrument("holistic.language_server.request", request:) do
        return respond_with_rejection(request) if Current.lifecycle.reject?(message.method)

        handler = ROUTES[message.method]

        return Response::NotFound.new if handler.nil?

        handler.call(request)
      end
    end

    private

    def respond_with_rejection(request)
      error_code =
        if Current.lifecycle.initialized?
          Protocol::INVALID_REQUEST_ERROR_CODE
        else
          Protocol::SERVER_NOT_INITIALIZED_ERROR_CODE
        end

      request.respond_with_error(code: error_code)
    end
  end
end
