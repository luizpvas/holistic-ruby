# frozen_string_literal: true

module Question::Ruby::Parser
  ParseCode = ->(application:, code:) do
    Current.set(application:) do
      program = ::SyntaxTree.parse(code)

      Visitor::ProgramVisitor.new.visit(program)
    end
  end

  ParseFile = ->(application:, file_path:) do
    Current.set(file_path:) do
      ParseCode[application:, code: ::File.read(file_path)]
    end
  end

  ParseDirectory = ->(application:, directory_path:) do
    ::Dir.glob("#{directory_path}/**/*.rb").map do |file_path|
      ParseFile[application:, file_path:]
    end
  end
end
