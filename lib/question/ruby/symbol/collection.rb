# frozen_string_literal: true

module Question::Ruby::Symbol
  class Collection
    attr_reader :application, :from_file_path_to_identifier

    def initialize(application:)
      @application = application
      @from_identifier_to_symbol = {}
      @from_file_path_to_identifier = ::Hash.new { |hash, key| hash[key] = ::Set.new }
    end

    AttemptingToIndexDifferentSymbolWithSameIdentifier = ::Class.new(::StandardError)

    def index(symbol)
      raise ::ArgumentError unless symbol.is_a?(::Question::Ruby::Symbol::Record)

      if @from_identifier_to_symbol.key?(symbol.identifier)
        if find(symbol.identifier) != symbol
          raise AttemptingToIndexDifferentSymbolWithSameIdentifier, "symbol #{symbol.identifier} already indexed"
        end
      else
        @from_identifier_to_symbol[symbol.identifier] = symbol
      end

      symbol.source_locations.each do |source_location|
        @from_file_path_to_identifier[source_location.file_path].add(symbol.identifier)
      end
    end

    def find(identifier)
      @from_identifier_to_symbol[identifier]
    end

    def delete_symbols_in_file(file_path)
      @from_file_path_to_identifier[file_path].each do |identifier|
        find(identifier).delete(file_path)

        @from_identifier_to_symbol.delete(identifier)
      end

      @from_file_path_to_identifier[file_path].clear
    end
    
    def list_symbols_in_file(file_path)
      @from_file_path_to_identifier[file_path].map { find(_1) }
    end

    def search(query)
      documents = @from_identifier_to_symbol.values.map(&:to_search_document).compact

      ::Question::FuzzySearch::Search.call(query:, documents:)
    end

    concerning :TestingHelpers do
      def find_reference_to(name)
        candidates =
          @from_identifier_to_symbol.values.select do |symbol|
            symbol.kind == :type_inference && symbol.record.clues.find { _1.name == name }
          end

        raise "could not find reference to #{name.inspect}" if candidates.empty?
        raise "found multiple references to #{name.inspect}" if candidates.size > 1

        candidates.first.record
      end
    end
  end
end
