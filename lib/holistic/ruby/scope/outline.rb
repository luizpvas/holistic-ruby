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
      scope.has_many(:children) + scope.has_many(:children).flat_map { QueryChildScopesRecursively[application, _1] }
    end

    QueryDependenciesRecursively = ->(application, outlined_scope, scope) do
      is_local_dependency = ->(reference) do
        scope = reference.has_one(:referenced_scope)

        scope == outlined_scope || Lexical.descendant?(child: scope, parent: outlined_scope)
      end

      dependencies = []

      scope.locations.each do |scope_location|
        application.references
          .list_references_in_file(scope_location.declaration.file.attr(:path))
          .filter { |reference| reference.has_one(:located_in_scope) == scope }
          .filter { |reference| reference.has_one(:referenced_scope).present? }
          .reject(&is_local_dependency)
          .tap { dependencies.concat(_1) }
      end

      scope.has_many(:children).map(&QueryDependenciesRecursively.curry[application, outlined_scope]).flatten.concat(dependencies)
    end

    def call(application:, scope:)
      declarations = QueryChildScopesRecursively.call(application, scope).sort_by { _1.attr(:fully_qualified_name) }

      dependencies = QueryDependenciesRecursively.call(application, scope, scope).uniq

      references = scope.has_many(:referenced_by)

      dependants = references.map { |reference| reference.has_one(:located_in_scope) }.uniq

      Result.new(declarations:, dependencies:, references:, dependants:)
    end
  end
end
