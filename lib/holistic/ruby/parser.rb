# frozen_string_literal: true

module Holistic::Ruby::Parser
  HasValidSyntax = ->(content) do
    ::SyntaxTree.parse(content)

    true
  rescue ::SyntaxTree::Parser::ParseError
    false
  end

  ParseFile = ->(application:, file_path:, content:) do
    program = ::SyntaxTree.parse(content)

    constant_resolution = ConstantResolution.new(scope_repository: application.scopes)

    file = ::Holistic::Document::File::Register.call(database: application.database, file_path:)

    visitor = ProgramVisitor.new(application:, constant_resolution:, file:)

    visitor.visit(program)
  rescue ::SyntaxTree::Parser::ParseError
    ::Holistic.logger.info("syntax error on file #{file.path}")
  end

  ParseDirectory = ->(application:, directory_path:) do
    ::Dir.glob("#{directory_path}/**/*.rb").map do |file_path|
      ParseFile.call(application:, file_path:, content: ::File.read(file_path))
    end
  end
end
