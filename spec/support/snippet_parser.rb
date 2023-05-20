# frozen_string_literal: true

module SnippetParser
  def parse_snippet(code)
    ::Question::Ruby::Application.new(root_directory: '.').tap do |application|
      ::Question::Ruby::Parser::ParseCode[application:, code:]
    end
  end

  def unfold_namespace_tree(application)
    
  end
end
