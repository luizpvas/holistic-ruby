# frozen_string_literal: true

module Holistic::Ruby::Reference
  module Delete
    extend self

    def call(database:, reference:)
      database.delete(reference.identifier)

      database.disconnect(source: reference.location.file, target: reference, name: :defines_references, inverse_of: :reference_defined_in_file)
      database.disconnect(source: reference.located_in_scope, target: reference, name: :contains_many_references, inverse_of: :located_in_scope)

      if reference.referenced_scope
        database.disconnect(source: reference.referenced_scope, target: reference, name: :referenced_by, inverse_of: :referenced_scope)
      end
    end
  end
end
