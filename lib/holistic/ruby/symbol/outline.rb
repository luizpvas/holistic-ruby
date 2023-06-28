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

    CrawlDeclarationsRecursively = ->(application, namespace) do
      namespace.children.flat_map do |subnamespace|
        symbols = [application.symbols.find(subnamespace.fully_qualified_name)]

        symbols.concat(CrawlDeclarationsRecursively.call(application, subnamespace))
      end
    end

    CrawlDependenciesRecursively = ->(application, outlined_namespace, namespace) do
      dependencies = []

      is_local_dependency = ->(symbol) do
        dependency = application.symbols.find(symbol.record.conclusion.dependency_identifier)

        dependency.namespace.eql?(outlined_namespace) || dependency.namespace.descendant?(outlined_namespace)
      end

      namespace.locations.each do |location|
        application.symbols
          .list_symbols_in_file(location.file_path)
          .filter { _1.kind == Kind::REFERENCE }
          .filter { _1.record.namespace == namespace }
          .reject(&is_local_dependency)
          .tap { dependencies.concat(_1) }
      end

      namespace.children.map(&CrawlDependenciesRecursively.curry[application, outlined_namespace]).flatten.concat(dependencies)
    end

    def call(application:, symbol:)
      declarations =
        if symbol.record.is_a?(::Holistic::Ruby::Namespace::Record)
          CrawlDeclarationsRecursively.call(application, symbol.record).sort_by { _1.identifier }
        else
          []
        end

      dependencies =
        if symbol.record.is_a?(::Holistic::Ruby::Namespace::Record)
          CrawlDependenciesRecursively.call(application, symbol.record, symbol.record)
        else
          []
        end

      references = application.dependencies.list_references(dependency_identifier: symbol.identifier)

      dependants = references.map { |symbol| symbol.record.namespace }.uniq

      Result.new(declarations:, dependencies:, references:, dependants:)
    end
  end
end
