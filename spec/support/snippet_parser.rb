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
end
