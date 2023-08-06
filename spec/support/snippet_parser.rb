# frozen_string_literal: true

module Support
  module SnippetParser
    def parse_snippet(code)
      application = ::Holistic::Application.new(name: "Snippet", root_directory: "snippet_parser")
      ::Holistic::Extensions::Ruby::Stdlib.register(application)

      file = ::Holistic::Document::File::Fake.new(path: "/snippet.rb", content: code)

      ::Holistic::Ruby::Parser::ParseFile.call(application:, file:)

      ::Holistic::Ruby::TypeInference::SolvePendingReferences.call(application:)

      application
    end

    # TODO: find a better name for this helper
    def parse_snippet_collection(&block)
      application = ::Holistic::Application.new(name: "Snippet", root_directory: "snippet_parser")
      ::Holistic::Extensions::Ruby::Stdlib.register(application)

      files = ::Object.new
      files.define_singleton_method(:add) do |file_path, code|
        file = ::Holistic::Document::File::Fake.new(path: file_path, content: code)

        ::Holistic::Ruby::Parser::ParseFile[application:, file:]
      end

      block.call(files)

      ::Holistic::Ruby::TypeInference::SolvePendingReferences.call(application:)

      application
    end
  end
end
