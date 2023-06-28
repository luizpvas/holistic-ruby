# frozen_string_literal: true

module Holistic::LanguageServer
  module Router
    extend self

    FROM_METHOD_TO_HANDLER = {
      # lifecycle messages
      "initialize" => Requests::Initialize,
      "shutdown"   => Requests::Shutdown,
      "exit"       => Requests::Exit,

      # language features
      "textDocument/declaration" => Requests::GoToDeclaration
    }.freeze

    def dispatch(message)
      ::Holistic.logger.info(message)

      handler = FROM_METHOD_TO_HANDLER[message.method]

      if !handler
        ::Holistic.logger.info("handler not defined for: #{message.method}")

        return Response::NotFound.new
      end

      handler.call(message).tap { ::Holistic.logger.info(_1) }
    end
  end
end
