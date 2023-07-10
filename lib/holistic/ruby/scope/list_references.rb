# frozen_string_literal: true

module Holistic::Ruby::Scope
  module ListReferences
    extend self

    def call(application:, cursor:)
      scope = application.scopes.find_by_cursor(cursor)

      return :not_found if scope.nil?

      query_references_to_scope_recursively = ->(scope) do
        references = application.references.list_references_to(scope.fully_qualified_name)

        references_to_child_scopes = scope.children.flat_map { query_references_to_scope_recursively.call(_1) }

        references + references_to_child_scopes
      end

      references = query_references_to_scope_recursively.call(scope)

      [:references_listed, {references:}]
    end
  end
end