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
      scope.children.flat_map do |sub_scope|
        symbols = [application.symbols.find(sub_scope.fully_qualified_name)]

        symbols.concat(CrawlDeclarationsRecursively.call(application, sub_scope))
      end
    end

    CrawlDependenciesRecursively = ->(application, outlined_scope, scope) do
      dependencies = []

      is_local_dependency = ->(symbol) do
        dependency = application.symbols.find(symbol.record.conclusion.dependency_identifier)

        dependency.scope.eql?(outlined_scope) || dependency.scope.descendant?(outlined_scope)
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

    def call(application:, symbol:)
      declarations =
        if symbol.record.is_a?(::Holistic::Ruby::Scope::Record)
          CrawlDeclarationsRecursively.call(application, symbol.record).sort_by { _1.identifier }
        else
          []
        end

      dependencies =
        if symbol.record.is_a?(::Holistic::Ruby::Scope::Record)
          CrawlDependenciesRecursively.call(application, symbol.record, symbol.record)
        else
          []
        end

      references = application.dependencies.list_references(dependency_identifier: symbol.identifier)

      dependants = references.map { |symbol| symbol.record.scope }.uniq

      Result.new(declarations:, dependencies:, references:, dependants:)
    end
  end
end
