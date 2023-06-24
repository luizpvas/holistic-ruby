# frozen_string_literal: true

module Holistic::LanguageServer
  module Router
    extend self

    FROM_METHOD_TO_HANDLER = {
      "initialize" => Requests::Initialize
    }.freeze

    def call(message)
      method = message["method"]

      handler = FROM_METHOD_TO_HANDLER[method]

      if !handler
        ::Holistic.logger.info("handler not defined for: #{method}")

        return
      end

      handler.call(message["params"])
    end
  end
end
