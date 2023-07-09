# frozen_string_literal: true

module Holistic::Ruby::Reference
  module Register
    extend self

    # TODO: remove `application:` argument, not needed.
    def call(application:, scope:, clues:, location:)
      reference = ::Holistic::Ruby::TypeInference::Reference.new(scope:, clues:, location:)

      # TODO: change the registration queue to some other abstraction
      ::Holistic::Ruby::Parser::Current.registration_queue.register(reference)

      # TODO: migrate to reference table
      application.symbols.index(reference.to_symbol)

      reference
    end
  end
end
