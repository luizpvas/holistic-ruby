# frozen_string_literal: true

module SnippetParser
  def parse_snippet(code)
    application = ::Question::Ruby::Application.new(name: "Snippet", root_directory: "snippet_parser")

    ::Question::Ruby::Parser::Current.set(file_path: "snippet.rb") do
      ::Question::Ruby::Parser::ParseCode[application:, code:]
    end

    ::Question::Ruby::Namespace::Symbol::Index[application, application.root_namespace]

    application
  end

  # TODO: find a better name for this helper
  def parse_snippet_collection(&block)
    application = ::Question::Ruby::Application.new(name: "Snippet", root_directory: "snippet_parser")

    files = ::Object.new
    files.define_singleton_method(:add) do |file_path, code|
      ::Question::Ruby::Parser::Current.set(file_path:) do
        ::Question::Ruby::Parser::ParseCode[application:, code:]
      end
    end

    block.call(files)

    ::Question::Ruby::Namespace::Symbol::Index[application, application.root_namespace]

    application
  end
end
