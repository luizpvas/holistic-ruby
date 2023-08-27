# frozen_string_literal: true

module Holistic::Ruby::Reference
  class Repository
    attr_reader :table

    def initialize(files:)
      @files = files
      
      @table = ::Holistic::Database::Table.new
    end

    # TODO: rename to `store`
    def register_reference(reference)
      table.store(reference.identifier, { reference: })
    end

    def find_by_cursor(cursor)
      @files.find(cursor.file_path)&.then do |file|
        file.references.find do |reference|
          reference.location.contains?(cursor)
        end
      end
    end

    def list_references_in_file(file_path)
      @files.find(file_path)&.references&.to_a || []
    end

    def list_references_to_scopes_in_file(scopes:, file_path:)
      scopes.list_scopes_in_file(file_path).flat_map do |scope|
        scope.referenced_by.to_a
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
