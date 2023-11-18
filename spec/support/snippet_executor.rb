# frozen_string_literal: true

module Support
  module SnippetExecutor
    def self.execute_script(code)
      application = ::Holistic::Application.boot(name: "Snippet", root_directory: "snippet_parser")

      ::Holistic::Ruby::Parser::ParseFile.call(application:, file_path: "/snippet.rb", content: code)
      ::Holistic::Ruby::Reference::TypeInference::ResolveEnqueued.call(application:)

      application
    end
  end
end
