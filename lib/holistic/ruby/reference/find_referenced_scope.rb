# frozen_string_literal: true

module Holistic::Ruby::Reference
  module FindReferencedScope
    extend self

    def call(application:, cursor:)
      reference = application.references.find_by_cursor(cursor)

      return :not_found if reference.nil?
      return :could_not_find_referenced_scope if reference.conclusion.dependency_identifier.nil?

      referenced_scope = application.scopes.find_by_fully_qualified_name(reference.conclusion.dependency_identifier)

      [:referenced_scope_found, {reference:, referenced_scope:}]
    end
  end
end
