# frozen_string_literal: true

module Holistic::Ruby::Scope
  module Outline
    extend self

    Result = ::Struct.new(
      :declarations,
      :dependencies,
      :references,
      :dependants,
      keyword_init: true
    )

    QueryChildScopesRecursively = ->(application, scope) do
      scope.lexical_children.to_a + scope.lexical_children.flat_map { QueryChildScopesRecursively[application, _1] }
    end

    QueryDependenciesRecursively = ->(application, outlined_scope, scope) do
      is_local_dependency = ->(reference) do
        scope = reference.referenced_scope

        scope == outlined_scope || Lexical.descendant?(child: scope, parent: outlined_scope)
      end

      dependencies = []

      scope.locations.each do |scope_location|
        application.references
          .list_references_in_file(scope_location.declaration.file.path)
          .filter { |reference| reference.located_in_scope == scope }
          .filter { |reference| reference.referenced_scope.present? }
          .reject(&is_local_dependency)
          .tap { dependencies.concat(_1) }
      end

      scope.lexical_children.map(&QueryDependenciesRecursively.curry[application, outlined_scope]).flatten.concat(dependencies)
    end

    def call(application:, scope:)
      declarations = QueryChildScopesRecursively.call(application, scope).sort_by { _1.fully_qualified_name }

      dependencies = QueryDependenciesRecursively.call(application, scope, scope).uniq

      references = scope.referenced_by

      dependants = references.map { |reference| reference.located_in_scope }.uniq

      Result.new(declarations:, dependencies:, references:, dependants:)
    end
  end
end
