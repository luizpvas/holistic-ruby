# frozen_string_literal: true

module Holistic::LanguageServer
  module Router
    extend self

    FROM_METHOD_TO_HANDLER = {
      "initialize" => Requests::Initialize,
      "shutdown"   => Requests::Shutdown,
      "exit"       => Requests::Exit
    }.freeze

    def dispatch(message)
      ::Holistic.logger.info(message)

      handler = FROM_METHOD_TO_HANDLER[message.method]

      if !handler
        ::Holistic.logger.info("handler not defined for: #{message.method}")

        return Response.not_found
      end

      handler.call(message).tap { ::Holistic.logger.info(_1) }
    end
  end
end
