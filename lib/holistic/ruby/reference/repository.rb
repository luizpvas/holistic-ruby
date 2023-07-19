# frozen_string_literal: true

module Holistic::Ruby::Reference
  class Repository
    attr_reader :table

    INDICES = [
      :file_path,
      :type_inference_status,
      :referenced_scope_fully_qualified_name
    ].freeze

    def initialize
      @table = ::Holistic::Database::Table.new(indices: INDICES)
    end

    def register_reference(reference)
      table.update({
        reference:,
        identifier: reference.identifier,
        file_path: reference.location.file_path,
        type_inference_status: reference.conclusion.status,
        referenced_scope_fully_qualified_name: reference.conclusion.dependency_identifier
      })
    end

    def find_by_cursor(cursor)
      table.filter(:file_path, cursor.file_path).map { _1[:reference] }.each do |reference|
        return reference if reference.location.contains?(cursor)
      end

      nil
    end

    def list_references_to(fully_qualified_scope_name)
      table.filter(:referenced_scope_fully_qualified_name, fully_qualified_scope_name).map { _1[:reference] }
    end

    def list_references_in_file(file_path)
      table.filter(:file_path, file_path).map { _1[:reference] }
    end

    def list_references_to_scopes_in_file(scopes:, file_path:)
      scopes.list_scopes_in_file(file_path).flat_map do |scope|
        table.filter(:referenced_scope_fully_qualified_name, scope.fully_qualified_name).map { _1[:reference] }
      end
    end

    def list_references_pending_type_inference_conclusion
      table.filter(:type_inference_status, ::Holistic::Ruby::TypeInference::STATUS_PENDING).map { _1[:reference] }
    end

    def delete(identifier)
      table.delete(identifier)
    end

    concerning :TestHelpers do
      def find_reference_to(scope_name)
        table.all.map { _1[:reference] }.find do |reference|
          reference.conclusion.dependency_identifier == scope_name || reference.clues.find { _1.to_s == scope_name }
        end
      end

      def find_by_code_content(code_content)
        table.all.map { _1[:reference] }.find do |reference|
          reference.clues.find { _1.to_s == code_content }
        end
      end
    end
  end
end
