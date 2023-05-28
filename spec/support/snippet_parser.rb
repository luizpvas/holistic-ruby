# frozen_string_literal: true

module SnippetParser
  def parse_snippet(code)
    application = ::Question::Ruby::Application.new(name: 'Snippet', root_directory: 'fake_snippet_parser')

    ::Question::Ruby::Parser::ParseCode[application:, code:]

    ::Question::Ruby::Namespace::Symbol::Index[application, application.root_namespace]

    application
  end
end
