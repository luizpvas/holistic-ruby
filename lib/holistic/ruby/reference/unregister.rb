# frozen_string_literal: true

module Holistic::Ruby::Reference
  module Unregister
    extend self

    def call(database:, reference:)
      database.delete(reference.identifier)

      database.disconnect(source: reference.location.file, target: reference, name: :defines_references, inverse_of: :reference_defined_in_file)
      database.disconnect(source: reference.has_one(:located_in_scope), target: reference, name: :contains_many_references, inverse_of: :located_in_scope)

      if reference.has_one(:referenced_scope)
        database.disconnect(source: reference.has_one(:referenced_scope), target: reference, name: :referenced_by, inverse_of: :referenced_scope)
      end
    end
  end
end
