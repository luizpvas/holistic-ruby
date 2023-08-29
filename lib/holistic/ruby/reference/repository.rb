# frozen_string_literal: true

module Holistic::Ruby::Reference
  class Repository
    attr_reader :database

    def initialize(database:)
      @database = database
    end

    def find_by_cursor(cursor)
      @database.find(cursor.file_path)&.then do |file|
        file.has_many(:defines_references).find do |reference|
          reference.attr(:location).contains?(cursor)
        end
      end
    end

    def list_references_in_file(file_path)
      @database.find(file_path)&.has_many(:defines_references) || []
    end

    def list_references_to_scopes_in_file(scopes:, file_path:)
      references = @database.find(file_path)&.has_many(:defines_scopes)&.flat_map do |scope|
        scope.has_many(:referenced_by)
      end

      references || []
    end

    concerning :TestHelpers do
      def all
        @database.all.filter { _1.attr(:clues).present? }
      end

      def find_reference_to(scope_name)
        @database.all.find do |node|
          node.has_one(:referenced_scope)&.attr(:fully_qualified_name) == scope_name || node.attr(:clues)&.find { _1.to_s == scope_name }
        end
      end

      def find_by_code_content(code_content)
        @database.all.find do |node|
          node.attr(:clues)&.find { _1.to_s == code_content }
        end
      end
    end
  end
end
