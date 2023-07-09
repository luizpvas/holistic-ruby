# frozen_string_literal: true

module Holistic::Ruby::Parser
  module LiveEditing::ProcessFileChanged
    extend self

    def call(application:, file:)
      references = application.dependencies.delete_references(dependency_file_path: file.path)

      delete_symbols_in_file(application:, file:) # TODO: remove
      unregister_scopes_in_file(application:, file:)

      parse_again(application:, file:)

      recalculate_type_inference_for_references(application:, references:)
    end

    private

    def delete_symbols_in_file(application:, file:)
      application.symbols.delete_symbols_in_file(file.path)
    end

    def unregister_scopes_in_file(application:, file:)
      application.scopes.list_scopes_in_file(file.path).each do |scope|
        ::Holistic::Ruby::Scope::Unregister.call(
          repository: application.scopes,
          fully_qualified_name: scope.fully_qualified_name,
          file_path: file.path
        )
      end
    end

    def parse_again(application:, file:)
      WrapParsingUnitWithProcessAtTheEnd.call(application:) do
        ParseFile.call(application:, file:)
      end
    end

    def recalculate_type_inference_for_references(application:, references:)
      references.each do |symbol|
        reference = symbol.record

        reference.conclusion = nil

        ::Holistic::Ruby::TypeInference::Solve.call(application:, reference:)
      end
    end
  end
end
