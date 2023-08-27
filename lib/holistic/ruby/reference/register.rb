# frozen_string_literal: true

module Holistic::Ruby::Reference
  module Register
    extend self

    def call(application:, scope:, clues:, location:)
      reference = ::Holistic::Ruby::Reference::Record.new(scope:, clues:, location:)

      application.references.register_reference(reference)
      
      application.type_inference_processing_queue.push(reference)

      location.file.connect_reference(reference)
    end
  end
end
