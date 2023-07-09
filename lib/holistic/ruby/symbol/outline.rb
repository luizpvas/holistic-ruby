# frozen_string_literal: true

module Holistic::Ruby::Symbol
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
      dependencies = []

      is_local_dependency = ->(symbol) do
        scope = application.scopes.find_by_fully_qualified_name(symbol.record.conclusion.dependency_identifier)

        scope.eql?(outlined_scope) || scope.descendant?(outlined_scope)
      end

      scope.locations.each do |location|
        application.symbols
          .list_symbols_in_file(location.file_path)
          .filter { _1.kind == Kind::REFERENCE }
          .filter { _1.record.scope == scope }
          .reject(&is_local_dependency)
          .tap { dependencies.concat(_1) }
      end

      scope.children.map(&CrawlDependenciesRecursively.curry[application, outlined_scope]).flatten.concat(dependencies)
    end

    def call(application:, scope:)
      declarations = CrawlDeclarationsRecursively.call(application, scope).sort_by { _1.fully_qualified_name }

      dependencies = CrawlDependenciesRecursively.call(application, scope, scope)

      references = application.dependencies.list_references(dependency_identifier: scope.fully_qualified_name)

      dependants = references.map { |symbol| symbol.record.scope }.uniq

      Result.new(declarations:, dependencies:, references:, dependants:)
    end
  end
end
