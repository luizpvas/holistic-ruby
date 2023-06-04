# frozen_string_literal: true

module Question::Ruby::Symbol
  class Index
    attr_reader :application

    def initialize(application:)
      @application = application
      @from_identifier_to_document = {}
      @from_file_path_to_identifier = ::Hash.new { |hash, key| hash[key] = [] }
    end

    def index(symbol)
      raise ::ArgumentError unless symbol.is_a?(::Question::Ruby::Symbol::Record)

      document = ToDocument[symbol]

      @from_identifier_to_document[document.identifier] = document

      symbol.source_locations.each do |source_location|
        @from_file_path_to_identifier[source_location.file_path] << document.identifier
      end
    end

    def find(identifier)
      @from_identifier_to_document[identifier]&.record
    end

    def get_symbols_in_file(file_path)
      @from_file_path_to_identifier[file_path].map { find(_1) }
    end

    def search(query)
      ::Question::FuzzySearch::Search.call(query:, documents: @from_identifier_to_document.values)
    end
  end
end
