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

    CrawlNamespaceDeclarationsRecursively = ->(application, namespace) do
      declarations = [application.symbols.find(namespace.fully_qualified_name)]

      # NOTE: Perhaps this inner loop looking for all symbols in file is an expensive operations?
      # Will there be any perceived different in performance making it O(1)?
      namespace.source_locations.each do |source_location|
        symbols = application.symbols.list_symbols_in_file(source_location.file_path)

        declarations_of_namespace =
          symbols.filter { _1.kind == :declaration && _1.record.namespace == namespace }

        declarations.concat(declarations_of_namespace)
      end

      namespace.children.map(&CrawlNamespaceDeclarationsRecursively.curry[application]).flatten.concat(declarations)
    end

    CrawlDependenciesRecursively = ->(application, outlined_namespace, namespace) do
      dependencies = []

      is_local_dependency = ->(symbol) do
        dependency = application.symbols.find(symbol.record.conclusion.dependency_identifier)

        dependency.namespace.eql?(outlined_namespace) || dependency.namespace.descendant?(outlined_namespace)
      end

      namespace.source_locations.each do |source_location|
        application.symbols
          .list_symbols_in_file(source_location.file_path)
          .filter { _1.kind == :type_inference }
          .filter { _1.record.namespace == namespace }
          .reject(&is_local_dependency)
          .tap { dependencies.concat(_1) }
      end

      namespace.children.map(&CrawlDependenciesRecursively.curry[application, outlined_namespace]).flatten.concat(dependencies)
    end

    def call(application:, symbol:)
      declarations =
        if symbol.record.is_a?(::Holistic::Ruby::Namespace::Record)
          CrawlNamespaceDeclarationsRecursively.call(application, symbol.record).sort_by { _1.identifier }
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

      Result.new(
        declarations:,
        dependencies:,
        references:,
        dependants:
      )
    end
  end
end
