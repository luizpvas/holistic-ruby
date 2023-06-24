# frozen_string_literal: true

module Holistic::LanguageServer
  module Router
    extend self

    FROM_METHOD_TO_HANDLER = {
      Requests::Initialize::METHOD => Requests::Initialize
    }.freeze

    def call(message)
      method = message["method"]

      handler = FROM_METHOD_TO_HANDLER[method]

      if !handler
        ::Holistic.logger.info("handler not defined for: #{method}")
      end

      # TODO: do something about it
    end
  end
end
