# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Repository
    attr_reader :database, :root

    def initialize(database:)
      @root = database.store(
        "root_scope", 
        Record.new("root_scope", {
          fully_qualified_name: "::",
          name: "::",
          kind: Kind::ROOT 
        })
      )

      @database = database
    end

    def find(fully_qualified_name)
      database.find(fully_qualified_name)
    end

    def find_by_cursor(cursor)
      database.find(cursor.file_path)&.then do |file|
        file.defines_scopes.find do |scope|
          scope.locations.any? { _1.declaration.contains?(cursor) }
        end
      end
    end

    def find_inner_most_scope_by_cursor(cursor)
      file = database.find(cursor.file_path)

      return nil if file.nil?

      matching_scopes = file.defines_scopes.filter_map do |scope|
        scope.locations.find { |location| location.body.contains?(cursor) }&.then do |location|
          { location:, scope: }
        end
      end

      inner_most_matching_scope = matching_scopes.sort_by { |match| match[:location].declaration.start_line }.last

      inner_most_matching_scope&.then { _1[:scope] }
    end

    def list_scopes_in_file(file_path)
      database.find(file_path)&.defines_scopes || []
    end
  end
end
