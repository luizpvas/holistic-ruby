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

    CrawlDeclarationsRecursively = ->(application, scope) do
      scope.children + scope.children.flat_map { CrawlDeclarationsRecursively[application, _1] }
    end

    CrawlDependenciesRecursively = ->(application, outlined_scope, scope) do
      is_local_dependency = ->(reference) do
        scope = application.scopes.find_by_fully_qualified_name(reference.conclusion.dependency_identifier)

        scope.eql?(outlined_scope) || scope.descendant?(outlined_scope)
      end

      dependencies = []

      scope.locations.each do |location|
        application.references
          .list_references_in_file(location.file_path)
          .filter { _1.scope == scope }
          .reject(&is_local_dependency)
          .tap { dependencies.concat(_1) }
      end

      scope.children.map(&CrawlDependenciesRecursively.curry[application, outlined_scope]).flatten.concat(dependencies)
    end

    def call(application:, scope:)
      declarations = CrawlDeclarationsRecursively.call(application, scope).sort_by { _1.fully_qualified_name }

      dependencies = CrawlDependenciesRecursively.call(application, scope, scope)

      references = application.references.list_references_to(scope.fully_qualified_name)

      dependants = references.map { |reference| reference.scope }.uniq

      Result.new(declarations:, dependencies:, references:, dependants:)
    end
  end
end
