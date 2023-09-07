# frozen_string_literal: true

module Holistic::Ruby::Reference
  module Store
    extend self

    def call(database:, processing_queue:, scope:, clues:, location:)
      record = Record.new(location.identifier, { identifier: location.identifier, clues:, location: })

      reference = database.store(location.identifier, record)

      reference.relation(:located_in_scope).add!(scope)
      reference.relation(:reference_defined_in_file).add!(location.file)

      # resolving reference to superclasses need to happen before resolving reference to methods because the
      # relation ancestor-descentand needs to exist beforehand.
      # in other words, if we try to resolve a reference to a method *before* resolving the superclass
      # we might get a miss.
      should_resolve_type_inference_with_high_priority =
        reference.find_clue(::Holistic::Ruby::TypeInference::Clue::ReferenceToSuperclass).present?

      if should_resolve_type_inference_with_high_priority
        processing_queue.push_with_high_priority(reference)
      else
        processing_queue.push(reference)
      end
    end
  end
end
