# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Repository
    attr_reader :database, :root

    def initialize(database:)
      database.define_connection(name: :children, inverse_of: :parent)

      @root = database.store("root_scope", { fully_qualified_name: "::", name: "::", kind: Kind::ROOT })

      @database = database
    end

    def store(fully_qualified_name:, name:, kind:, locations:)
      database.store(fully_qualified_name, { fully_qualified_name:, name:, kind:, locations: })
    end

    def find(fully_qualified_name)
      database.find(fully_qualified_name)
    end

    def find_by_cursor(cursor)
      database.find(cursor.file_path)&.then do |file|
        file.has_many(:defines_scopes).find do |scope|
          scope.attr(:locations).any? { _1.declaration.contains?(cursor) }
        end
      end
    end

    def find_inner_most_scope_by_cursor(cursor)
      file = database.find(cursor.file_path)

      return nil if file.nil?

      matching_scopes = file.has_many(:defines_scopes).filter do |scope|
        scope.attr(:locations).any? { _1.body.contains?(cursor) }
      end

      matching_scopes.last
    end

    # TODO rename to `delete_scope`
    def delete_by_fully_qualified_name(fully_qualified_name)
      database.delete(fully_qualified_name)
    end

    def list_scopes_in_file(file_path)
      database.find(file_path)&.has_many(:defines_scopes) || []
    end
  end
end
