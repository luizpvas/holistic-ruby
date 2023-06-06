# frozen_string_literal: true

module SnippetParser
  def parse_snippet(code)
    application = ::Question::Ruby::Application.new(name: "Snippet", root_directory: "snippet_parser")

    file = ::Question::SourceCode::File::Fake.new("snippet.rb", code)

    ::Question::Ruby::Parser::ParseFile[application:, file:]

    ::Question::Ruby::Namespace::Symbol::Index[application, application.root_namespace]

    application
  end

  # TODO: find a better name for this helper
  def parse_snippet_collection(&block)
    application = ::Question::Ruby::Application.new(name: "Snippet", root_directory: "snippet_parser")

    files = ::Object.new
    files.define_singleton_method(:add) do |file_path, code|
      file = ::Question::SourceCode::File::Fake.new(file_path, code)

      ::Question::Ruby::Parser::ParseFile[application:, file:]
    end

    block.call(files)

    ::Question::Ruby::Namespace::Symbol::Index[application, application.root_namespace]

    application
  end
end
