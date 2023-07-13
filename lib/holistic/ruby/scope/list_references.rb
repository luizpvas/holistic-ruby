# frozen_string_literal: true

module Holistic::Ruby::Scope
  module ListReferences
    extend self

    QueryReferencesRecursively = ->(application, scope) do
      references_to_scope = application.references.list_references_to(scope.fully_qualified_name)

      references_to_child_scopes = scope.children.flat_map { QueryReferencesRecursively.call(application, _1) }

      references_to_scope + references_to_child_scopes
    end

    def call(application:, cursor:)
      scope = application.scopes.find_by_cursor(cursor)

      return :not_found if scope.nil?

      references = QueryReferencesRecursively.call(application, scope)

      [:references_listed, {references:}]
    end
  end
end