# frozen_string_literal: true

module Holistic::Ruby::Reference
  module Store
    extend self

    def call(database:, processing_queue:, scope:, clues:, location:)
      record = Record.new(location.identifier, { identifier: location.identifier, clues:, location: })

      reference = database.store(location.identifier, record)

      reference.relation(:located_in_scope).add!(scope)
      reference.relation(:reference_defined_in_file).add!(location.file)

      processing_queue.push(reference)
    end
  end
end
