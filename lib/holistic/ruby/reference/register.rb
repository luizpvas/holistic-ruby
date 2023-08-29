# frozen_string_literal: true

module Holistic::Ruby::Reference
  module Register
    extend self

    # TODO: receive database + processing_queue instead of application. Narrow down requirements.

    def call(application:, scope:, clues:, location:)
      reference = application.database.store(location.identifier, {
        identifier: location.identifier,
        clues:,
        location:
      })

      application.database.connect(source: scope, target: reference, name: :contains_many_references, inverse_of: :located_in_scope)
      application.database.connect(source: location.file, target: reference, name: :defines_references, inverse_of: :reference_defined_in_file)

      application.type_inference_processing_queue.push(reference)
    end
  end
end
