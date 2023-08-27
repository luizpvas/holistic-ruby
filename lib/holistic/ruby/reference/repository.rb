# frozen_string_literal: true

module Holistic::Ruby::Reference
  class Repository
    attr_reader :table

    INDICES = [
      :referenced_scope_fully_qualified_name
    ].freeze

    def initialize(files:)
      @files = files
      
      @table = ::Holistic::Database::Table.new(indices: INDICES)
    end

    # TODO: rename to `store`
    def register_reference(reference)
      table.store(reference.identifier, {
        reference:,
        type_inference_status: reference.conclusion.status,
        referenced_scope_fully_qualified_name: reference.conclusion.dependency_identifier
      })
    end

    def find_by_cursor(cursor)
      @files.find(cursor.file_path)&.then do |file|
        file.references.find do |reference|
          reference.location.contains?(cursor)
        end
      end
    end

    def list_references_to(fully_qualified_scope_name)
      table.filter(:referenced_scope_fully_qualified_name, fully_qualified_scope_name).map { _1[:reference] }
    end

    def list_references_in_file(file_path)
      @files.find(file_path)&.references&.to_a || []
    end

    def list_references_to_scopes_in_file(scopes:, file_path:)
      scopes.list_scopes_in_file(file_path).flat_map do |scope|
        list_references_to(scope.fully_qualified_name)
      end
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
