# frozen_string_literal: true

module Holistic::Ruby::Reference
  module Unregister
    extend self

    def call(repository:, reference:)
      repository.delete(reference.attr(:identifier))

      repository.database.disconnect(source: reference.attr(:location).file, target: reference, name: :defines_references, inverse_of: :reference_defined_in_file)
      repository.database.disconnect(source: reference.has_one(:located_in_scope), target: reference, name: :contains_many_references, inverse_of: :located_in_scope)

      if reference.has_one(:referenced_scope)
        repository.database.disconnect(source: reference.has_one(:referenced_scope), target: reference, name: :referenced_by, inverse_of: :referenced_scope)
      end
    end
  end
end
