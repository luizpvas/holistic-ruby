# frozen_string_literal: true

module Holistic::Ruby::Reference
  module Delete
    extend self

    def call(database:, reference:)
      database.delete(reference.identifier)

      reference.relation(:reference_defined_in_file).delete!(reference.location.file)
      reference.relation(:located_in_scope).delete!(reference.located_in_scope)

      if reference.referenced_scope
        reference.relation(:referenced_scope).delete!(reference.referenced_scope)
      end
    end
  end
end
