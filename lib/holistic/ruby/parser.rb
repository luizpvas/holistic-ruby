# frozen_string_literal: true

module Holistic::Ruby::Parser
  ParseCode = ->(application:, code:) do
    scope = application.root_scope
    constant_resolution_possibilities = ConstantResolutionPossibilities.root_scope

    Current.set(application:, scope:, constant_resolution_possibilities:) do
      program = ::SyntaxTree.parse(code)

      Visitor::ProgramVisitor.new.visit(program)
    end
  end

  ParseFile = ->(application:, file:) do
    Current.set(file:) do
      ParseCode[application:, code: file.read]
    end
  end

  ParseDirectory = ->(application:, directory_path:) do
    ::Dir.glob("#{directory_path}/**/*.rb").map do |file_path|
      file = ::Holistic::Document::File.new(path: file_path)

      ParseFile[application:, file:]
    end
  end
end
