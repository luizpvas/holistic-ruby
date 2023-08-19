# frozen_string_literal: true

module Holistic::Ruby::Parser
  module LiveEditing::ProcessFileChanged
    extend self

    def call(application:, file:)
      # TODO: do not build the AST twice
      return unless HasValidSyntax[file:]

      references_to_recalculate = identify_references_to_recalculate(application:, file:)

      unregister_scopes_in_file(application:, file:)
      unregsiter_references_in_file(application:, file:)

      parse_again(application:, file:)

      recalculate_type_inference_for_references(application:, references: references_to_recalculate)
    end

    private

    def identify_references_to_recalculate(application:, file:)
      # we need to reject references declared in the same because they're already going to be
      # reparsed. If we don't do that, we'll end up with duplicated reference records. 

      application.references
        .list_references_to_scopes_in_file(scopes: application.scopes, file_path: file.path)
        .reject { _1.location.file_path == file.path }
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

    def unregsiter_references_in_file(application:, file:)
      application.references.list_references_in_file(file.path).each do |reference|
        ::Holistic::Ruby::Reference::Unregister.call(
          repository: application.references,
          reference: reference
        )
      end
    end

    def parse_again(application:, file:)
      ParseFile.call(application:, file:)

      ::Holistic::Ruby::TypeInference::SolvePendingReferences.call(application:)
    end

    def recalculate_type_inference_for_references(application:, references:)
      references.each do |reference|
        reference.conclusion = ::Holistic::Ruby::TypeInference::Conclusion.pending

        ::Holistic::Ruby::TypeInference::Solve.call(application:, reference:)
      end
    end
  end
end
