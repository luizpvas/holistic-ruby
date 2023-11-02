# frozen_string_literal: true

module Support
  module SnippetParser
    def parse_snippet(code)
      application = ::Holistic::Application.new(name: "Snippet", root_directory: "snippet_parser")
      ::Holistic::Extensions::Ruby::Stdlib.register(application)

      ::Holistic::Ruby::Parser::ParseFile.call(application:, file_path: "/snippet.rb", content: code)

      ::Holistic::Ruby::TypeInference::ResolvePendingReferences.call(application:)

      application
    end

    # TODO: find a better name for this helper
    def parse_snippet_collection(&block)
      application = ::Holistic::Application.new(name: "Snippet", root_directory: "snippet_parser")
      ::Holistic::Extensions::Ruby::Stdlib.register(application)

      files = ::Object.new
      files.define_singleton_method(:add) do |file_path, code|
        ::Holistic::Ruby::Parser::ParseFile.call(application:, file_path:, content: code)
      end

      block.call(files)

      ::Holistic::Ruby::TypeInference::ResolvePendingReferences.call(application:)

      application
    end
  end
end
