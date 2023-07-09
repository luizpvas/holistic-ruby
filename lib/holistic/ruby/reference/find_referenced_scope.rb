# frozen_string_literal: true

module Holistic::Ruby::Reference
  module FindReferencedScope
    extend self

    def call(application:, cursor:)
      # TODO: look for reference in `application.references` after killing the symbol abstraction
      reference = application.symbols.find_by_cursor(cursor)

      return :not_found if reference.nil?
      return :could_not_find_referenced_scope if reference.record.conclusion.nil?

      referenced_scope = application.scopes.find_by_fully_qualified_name(reference.record.conclusion.dependency_identifier)

      [:referenced_scope_found, {reference: reference.record, referenced_scope:}]
    end
  end
end
