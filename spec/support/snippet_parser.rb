# frozen_string_literal: true

module SnippetParser
  def parse_snippet(code)
    ::Question::Ruby::Application.new(name: 'Snippet', root_directory: '.').tap do |application|
      ::Question::Ruby::Parser::ParseCode[application:, code:]
    end
  end
end
