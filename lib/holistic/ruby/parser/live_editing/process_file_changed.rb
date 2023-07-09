# frozen_string_literal: true

module Holistic::Ruby::Parser
  module LiveEditing::ProcessFileChanged
    extend self

    def call(application:, file:)
      references = application.references.list_references_to_scopes_in_file(scopes: application.scopes, file_path: file.path)

      unregister_scopes_in_file(application:, file:)
      unregsiter_references_in_file(application:, file:)

      parse_again(application:, file:)

      recalculate_type_inference_for_references(application:, references:)
    end

    private

    def unregister_scopes_in_file(application:, file:)
      application.scopes.list_scopes_in_file(file.path).each do |scope|
        ::Holistic::Ruby::Scope::Unregister.call(
          repository: application.scopes,
          fully_qualified_name: scope.fully_qualified_name,
          file_path: file.path
        )
      end
    end

    def unregsiter_references_in_file(application:, file:)
      application.references.list_references_in_file(file.path).each do |reference|
        ::Holistic::Ruby::Reference::Unregister.call(
          repository: application.references,
          reference: reference
        )
      end
    end

    def parse_again(application:, file:)
      WrapParsingUnitWithProcessAtTheEnd.call(application:) do
        ParseFile.call(application:, file:)
      end
    end

    def recalculate_type_inference_for_references(application:, references:)
      references.each do |reference|
        reference.conclusion = ::Holistic::Ruby::TypeInference::Conclusion.pending

        ::Holistic::Ruby::TypeInference::Solve.call(application:, reference:)
      end
    end
  end
end
