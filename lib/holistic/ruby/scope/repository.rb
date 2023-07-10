# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Repository
    attr_reader :table

    def initialize
      @table = ::Holistic::Database::Table.new(indices: [:file_paths])
    end

    def register_scope(scope)
      table.update({
        identifier: scope.fully_qualified_name,
        file_paths: scope.locations.map(&:file_path),
        scope:
      })
    end

    def find_by_fully_qualified_name(fully_qualified_name)
      table.find(fully_qualified_name).try(:dig, :scope)
    end

    def find_by_cursor(cursor)
      table.filter(:file_paths, cursor.file_path).map { _1[:scope] }.each do |scope|
        return scope if scope.locations.any? { _1.contains?(cursor) }
      end

      nil
    end

    def delete_by_fully_qualified_name(fully_qualified_name)
      table.delete(fully_qualified_name)
    end

    def list_scopes_in_file(file_path)
      table.filter(:file_paths, file_path).map { _1[:scope] }
    end
  end
end
