# frozen_string_literal: true

module SnippetParser
  def parse_snippet(code)
    application = ::Question::Ruby::Application::Record.new(name: "Snippet", root_directory: "snippet_parser")

    file = ::Question::SourceCode::File::Fake.new("snippet.rb", code)

    ::Question::Ruby::Parser::WrapParsingUnitWithProcessAtTheEnd.call(application:) do
      ::Question::Ruby::Parser::ParseFile.call(application:, file:)
    end

    application
  end

  # TODO: find a better name for this helper
  def parse_snippet_collection(&block)
    application = ::Question::Ruby::Application::Record.new(name: "Snippet", root_directory: "snippet_parser")

    files = ::Object.new
    files.define_singleton_method(:add) do |file_path, code|
      file = ::Question::SourceCode::File::Fake.new(file_path, code)

      ::Question::Ruby::Parser::ParseFile[application:, file:]
    end

    ::Question::Ruby::Parser::WrapParsingUnitWithProcessAtTheEnd.call(application:) do
      block.call(files)
    end

    application
  end
end
