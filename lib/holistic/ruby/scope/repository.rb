# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Repository
    attr_reader :table

    def initialize
      @table = ::Holistic::Database::Table.new(indices: [:locations])
    end

    def register_scope(scope)
      table.update({
        identifier: scope.fully_qualified_name,
        locations: scope.locations.map(&:file_path),
        scope:
      })
    end

    def find_by_fully_qualified_name(fully_qualified_name)
      table.find(fully_qualified_name).try(:dig, :scope)
    end

    def delete_scopes_in_file(file_path)
      raise "todo"
    end
  end
end
