# frozen_string_literal: true

module Question::Ruby::Symbol
  class Index
    attr_reader :application

    def initialize(application:)
      @application = application
      @documents = {}
    end

    def index(symbol)
      raise ::ArgumentError unless symbol.is_a?(::Question::Ruby::Symbol::Record)

      document = ToDocument[symbol]

      @documents[document.identifier] = document
    end

    def find(identifier)
      @documents[identifier]&.record
    end

    def search(query)
      ::Question::FuzzySearch::Search.call(query:, documents: @documents.values)
    end
  end
end
