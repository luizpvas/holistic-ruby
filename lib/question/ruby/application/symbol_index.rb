# frozen_string_literal: true

class Question::Ruby::Application
  class SymbolIndex
    attr_reader :application

    def initialize(application:)
      @application = application
      @documents = {}

      index_namespace_recursively!(application.root_namespace)
    end

    def search(query)
      ::Question::FuzzySearch::Search.call(query:, documents: @documents.values)
    end

    private
      def index_namespace_recursively!(namespace)
        uuid = ::SecureRandom.uuid

        document = ::Question::FuzzySearch::Document.new(
          uuid:,
          text: namespace.fully_qualified_name,
          record: namespace
        )

        @documents[::SecureRandom.uuid] = document

        namespace.children.each(&method(:index_namespace_recursively!))
      end
  end
end
