# frozen_string_literal: true

module Holistic::Ruby::Reference
  module Store
    extend self

    def call(database:, processing_queue:, scope:, clues:, location:)
      record = Record.new(location.identifier, { identifier: location.identifier, clues:, location: })

      reference = database.store(location.identifier, record)

      database.connect(source: scope, target: reference, name: :contains_many_references, inverse_of: :located_in_scope)
      database.connect(source: location.file, target: reference, name: :defines_references, inverse_of: :reference_defined_in_file)

      processing_queue.push(reference)
    end
  end
end
