# frozen_string_literal: true

module Support
  module SnippetExecutor
    def self.execute_script(code)
      application = ::Holistic::Application.new(name: "Snippet", root_directory: "snippet_parser")
      ::Holistic::Extensions::Ruby::Stdlib.register(application)

      ::Holistic::Ruby::Parser::ParseFile.call(application:, file_path: "/snippet.rb", content: code)
      ::Holistic::Ruby::Reference::TypeInference::ResolveEnqueued.call(application:)

      application
    end
  end
end
