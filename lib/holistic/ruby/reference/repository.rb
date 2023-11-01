# frozen_string_literal: true

module Holistic::Ruby::Reference
  class Repository
    attr_reader :database

    def initialize(database:)
      @database = database
    end

    def find_by_cursor(cursor)
      list_references_in_file(cursor.file_path).find do |reference|
        reference.location.contains?(cursor)
      end
    end

    def list_references_in_file(file_path)
      @database.find(file_path)&.defines_references || []
    end

    def list_references_to_scopes_in_file(scopes:, file_path:)
      references = @database.find(file_path)&.defines_scopes&.flat_map do |scope|
        scope.referenced_by.to_a
      end

      references || []
    end

    concerning :TestHelpers do
      def all
        @database.all.filter { _1.is_a?(Record) }
      end

      def find_reference_to(scope_name)
        all.find do |node|
          node.referenced_scope&.fully_qualified_name == scope_name || node.clues&.find { _1.to_s == scope_name }
        end
      end

      def find_by_code_content(code_content)
        all.find do |node|
          node.clues&.find { _1.to_s == code_content }
        end
      end
    end
  end
end
