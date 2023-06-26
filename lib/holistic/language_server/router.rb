# frozen_string_literal: true

module Holistic::LanguageServer
  module Router
    extend self

    FROM_METHOD_TO_HANDLER = {
      "initialize" => Requests::Initialize,
      "shutdown"   => Requests::Shutdown
    }.freeze

    def dispatch(message)
      ::Holistic.logger.info(message)

      handler = FROM_METHOD_TO_HANDLER[message.method]

      if !handler
        ::Holistic.logger.info("handler not defined for: #{message.method}")

        return
      end

      response = handler.call(message)

      ::Holistic.logger.info(response)

      response
    end
  end
end
