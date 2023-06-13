# frozen_string_literal: true

module Question::Ruby::Symbol
  class Collection
    attr_reader :application, :from_file_path_to_identifier, :from_file_path_to_type_inference_dependencies

    def initialize(application:)
      @application = application
      @from_identifier_to_document = {}
      @from_file_path_to_identifier = ::Hash.new { |hash, key| hash[key] = ::Set.new }
      @from_file_path_to_type_inference_dependencies = ::Hash.new { |hash, key| hash[key] = ::Set.new }
    end

    AttemptingToIndexDifferentSymbolWithSameIdentifier = ::Class.new(::StandardError)

    def index(symbol)
      raise ::ArgumentError unless symbol.is_a?(::Question::Ruby::Symbol::Record)

      document = ToDocument[symbol]

      if @from_identifier_to_document.key?(symbol.identifier)
        if find(symbol.identifier) != symbol
          raise AttemptingToIndexDifferentSymbolWithSameIdentifier, "symbol #{symbol.identifier} already indexed"
        end
      else
        @from_identifier_to_document[document.identifier] = document
      end

      symbol.source_locations.each do |source_location|
        @from_file_path_to_identifier[source_location.file_path].add(document.identifier)
      end
    end

    def register_type_inference_dependency(file_path, symbol_identifier)
      # whenever the `file_path` changes, we need to re-evaluate the type inference for all `symbol_identifier`
      @from_file_path_to_type_inference_dependencies[file_path].add(symbol_identifier)
    end

    def delete_type_inference_dependencies(file_path)
      @from_file_path_to_type_inference_dependencies[file_path].clear
    end

    # TODO: rename to `list_dependants_of_file`
    def list_symbols_where_type_inference_resolves_to_file(file_path)
      @from_file_path_to_type_inference_dependencies[file_path].map { find(_1) }
    end

    def find(identifier)
      @from_identifier_to_document[identifier]&.record
    end

    def delete_symbols_in_file(file_path)
      @from_file_path_to_identifier[file_path].each do |identifier|
        find(identifier).delete(file_path)

        @from_identifier_to_document.delete(identifier)
      end

      @from_file_path_to_identifier[file_path].clear
    end
    
    def list_symbols_in_file(file_path)
      @from_file_path_to_identifier[file_path].map { find(_1) }
    end

    def search(query)
      ::Question::FuzzySearch::Search.call(query:, documents: @from_identifier_to_document.values)
    end

    concerning :TestingHelpers do
      def find_reference_to(name)
        candidates =
          @from_identifier_to_document.values.select do |document|
            symbol = document.record

            symbol.kind == :type_inference && symbol.record.clues.find { _1.name == name }
          end

        raise "could not find reference to #{name.inspect}" if candidates.empty?
        raise "found multiple references to #{name.inspect}" if candidates.size > 1

        candidates.first.record.record
      end
    end
  end
end
