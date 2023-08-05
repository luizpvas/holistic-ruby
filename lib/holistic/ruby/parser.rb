# frozen_string_literal: true

module Holistic::Ruby::Parser
  ParseFile = ->(application:, file:) do
    program = ::SyntaxTree.parse(file.read)

    constant_resolution = ConstantResolution.new(
      scope_repository: application.scopes,
      root_scope: application.root_scope
    )

    visitor = ProgramVisitor.new(application:, constant_resolution:, file:)

    visitor.visit(program)
  end

  ParseDirectory = ->(application:, directory_path:) do
    ::Dir.glob("#{directory_path}/**/*.rb").map do |file_path|
      file = ::Holistic::Document::File.new(path: file_path)

      ParseFile[application:, file:]
    end
  end
end
