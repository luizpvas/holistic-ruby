# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Repository
    attr_reader :table

    def initialize(files:)
      @files = files

      @table = ::Holistic::Database::Table.new
    end

    def store(scope)
      table.store(scope.fully_qualified_name, { scope: })
    end

    def find_by_fully_qualified_name(fully_qualified_name)
      table.find(fully_qualified_name).try(:dig, :scope)
    end

    def find_by_cursor(cursor)
      file = @files.find(cursor.file_path)

      return nil if file.nil?

      file.scopes.find do |scope|
        scope.locations.any? { _1.declaration.contains?(cursor) }
      end
    end

    def find_inner_most_scope_by_cursor(cursor)
      file = @files.find(cursor.file_path)

      return nil if file.nil?

      matching_scopes = file.scopes.filter do |scope|
        scope.locations.any? { _1.body.contains?(cursor) }
      end

      matching_scopes.last
    end

    def delete_by_fully_qualified_name(fully_qualified_name)
      table.delete(fully_qualified_name)
    end

    def list_scopes_in_file(file_path)
      @files.find(file_path)&.scopes&.to_a || []
    end
  end
end
