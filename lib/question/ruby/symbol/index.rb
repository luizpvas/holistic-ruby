# frozen_string_literal: true

module Question::Ruby::Symbol
  class Index
    attr_reader :application

    def initialize(application:)
      @application = application
      @documents = {}

      index_namespace_recursively!(application.root_namespace)
    end

    def find(uuid) = @documents[uuid]

    def search(query)
      ::Question::FuzzySearch::Search.call(query:, documents: @documents.values)
    end

    private
      def index_namespace_recursively!(namespace)
        uuid = namespace.fully_qualified_name

        document = ::Question::FuzzySearch::Document.new(
          uuid:,
          text: namespace.fully_qualified_name,
          record: namespace
        )

        @documents[uuid] = document

        namespace.children.each(&method(:index_namespace_recursively!))
      end
  end
end
