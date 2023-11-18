# frozen_string_literal: true

module Holistic::Ruby::TableOfContents
  module Store
    extend self

    def call(database:, scope:, identifier:, type:)
      key = "table_of_contents:#{scope.fully_qualified_name}"

      table_of_contents =
        if (table_of_contents = database.find(key))
          table_of_contents
        else
          table_of_contents = Record.new(key, { items: {} })
          database.store(key, table_of_contents)
        end

      table_of_contents.items[identifier] = Item.new(type:)

      table_of_contents
    end
  end
end
