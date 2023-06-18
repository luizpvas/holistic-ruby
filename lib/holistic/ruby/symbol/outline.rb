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

    def call(application:, symbol:)
      declarations = []

      if symbol.record.is_a?(::Holistic::Ruby::Namespace::Record)
        namespace = symbol.record

        namespace.children.each do |child_namespace|
          declarations << application.symbols.find(child_namespace.fully_qualified_name)

          namespace.source_locations.each do |source_location|
            symbols = application.symbols.list_symbols_in_file(source_location.file_path)

            declarations_of_namespace =
              symbols.filter { _1.kind == :declaration && _1.record.namespace == namespace }

            declarations.concat(declarations_of_namespace)
          end
        end
      end

      references = application.dependencies.list_references(dependency_identifier: symbol.identifier)

      dependants = references.map { |symbol| symbol.record.namespace }.uniq

      Result.new(
        declarations:,
        dependencies: [],
        references:,
        dependants:
      )
    end
  end
end
