# frozen_string_literal: true

module Holistic::Ruby::Parser
  module LiveEditing::ProcessFileChanged
    extend self

    def call(application:, file_path:, content:)
      # TODO: do not build the AST twice
      return unless HasValidSyntax[content]

      references_to_recalculate = identify_references_to_recalculate(application:, file_path:)

      unregister_scopes_in_file(application:, file_path:)
      unregsiter_references_in_file(application:, file_path:)

      parse_again(application:, file_path:, content:)

      recalculate_type_inference_for_references(application:, references: references_to_recalculate)
    end

    private

    def identify_references_to_recalculate(application:, file_path:)
      # we need to reject references declared in the same because they're already going to be
      # reparsed. If we don't do that, we'll end up with duplicated reference records. 

      application.references
        .list_references_to_scopes_in_file(scopes: application.scopes, file_path: file_path)
        .reject { _1.location.file.path == file_path }
    end

    def unregister_scopes_in_file(application:, file_path:)
      application.scopes.list_scopes_in_file(file_path).each do |scope|
        ::Holistic::Ruby::Scope::Unregister.call(
          repository: application.scopes,
          fully_qualified_name: scope.fully_qualified_name,
          file_path:
        )
      end
    end

    def unregsiter_references_in_file(application:, file_path:)
      application.references.list_references_in_file(file_path).each do |reference|
        ::Holistic::Ruby::Reference::Unregister.call(
          repository: application.references,
          reference: reference
        )
      end
    end

    def parse_again(application:, file_path:, content:)
      ParseFile.call(application:, file_path:, content:)

      ::Holistic::Ruby::TypeInference::SolvePendingReferences.call(application:)
    end

    def recalculate_type_inference_for_references(application:, references:)
      references.each do |reference|
        reference.referenced_scope.disconnect_referenced_by(reference)
        reference.disconnect_referenced_scope

        ::Holistic::Ruby::TypeInference::Solve.call(application:, reference:)
      end
    end
  end
end
