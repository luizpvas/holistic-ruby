# frozen_string_literal: true

module Holistic::Ruby::Parser
  module LiveEditing::ProcessFileChanged
    extend self

    def call(application:, file_path:, content:)
      # TODO: do not build the AST twice
      return unless HasValidSyntax[content]

      enqueue_references_to_reresolve!(application:, file_path:)

      delete_scopes_in_file(application:, file_path:)
      delete_references_in_file(application:, file_path:)

      ParseFile.call(application:, file_path:, content:)

      ::Holistic::Ruby::Reference::TypeInference::ResolveEnqueued.call(application:)
    end

    private

    def enqueue_references_to_reresolve!(application:, file_path:)
      # we need to reject references declared in the same because they're already going to be
      # reparsed. If we don't do that, we'll end up resolving the same reference twice.
      references_to_reresolve = application.references
        .list_references_to_scopes_in_file(scopes: application.scopes, file_path: file_path)
        .reject { _1.location.file.path == file_path }

      references_to_reresolve.each do |reference|
        reference.relation(:referenced_scope).delete!(reference.referenced_scope)

        application.type_inference_resolving_queue.push(reference)
      end
    end

    def delete_scopes_in_file(application:, file_path:)
      application.scopes.list_scopes_in_file(file_path).each do |scope|
        ::Holistic::Ruby::Scope::Delete.call(
          database: application.database,
          fully_qualified_name: scope.fully_qualified_name,
          file_path:
        )
      end
    end

    def delete_references_in_file(application:, file_path:)
      application.references.list_references_in_file(file_path).each do |reference|
        ::Holistic::Ruby::Reference::Delete.call(
          database: application.database,
          reference: reference
        )
      end
    end
  end
end
