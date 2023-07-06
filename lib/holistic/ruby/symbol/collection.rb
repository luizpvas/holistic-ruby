# frozen_string_literal: true

module Holistic::Ruby::Symbol
  class Collection
    attr_reader :table

    def initialize
      @table = ::Holistic::Database::Table.new(indices: [:locations])
    end

    def index(symbol)
      table.update({
        identifier: symbol.identifier,
        locations: symbol.locations.map(&:file_path),
        symbol: symbol
      })
    end

    def find(identifier)
      table.find(identifier)&.dig(:symbol)
    end

    def find_by_cursor(cursor)
      table.filter(:locations, cursor.file_path).each do |record|
        symbol = record[:symbol]

        return symbol if symbol.locations.any? { _1.contains?(cursor) }
      end

      nil
    end

    def delete_symbols_in_file(file_path)
      table.filter(:locations, file_path).each do |record|
        record[:symbol].delete(file_path)

        table.delete(record[:identifier])
      end
    end
    
    def list_symbols_in_file(file_path)
      table.filter(:locations, file_path).map { _1[:symbol] }
    end

    concerning :TestingHelpers do
      # TODO: return a symbol instead of `Reference`?
      def find_reference_to(name)
        references_symbols = find_references_to(name)

        raise "could not find reference to #{name.inspect}" if references_symbols.empty?
        raise "found multiple references to #{name.inspect}" if references_symbols.size > 1

        references_symbols.first.record
      end

      def find_references_to(name)
        table.all.filter do |record|
          symbol = record[:symbol]

          next if symbol.kind != Kind::REFERENCE

          symbol.record.conclusion&.dependency_identifier == name || symbol.record.clues.find { _1.name == name }
        end.map { _1[:symbol] }
      end
    end
  end
end
