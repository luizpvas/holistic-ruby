# frozen_string_literal: true

module Question::Ruby::Parser
  ParseCode = ->(application:, code:) do
    namespace = application.root_namespace
    resolution = ::Question::Ruby::Constant::Resolution.new

    Current.set(application:, namespace:, resolution:) do
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
      file = ::Question::SourceCode::File::Disk.new(path: file_path)

      ParseFile[application:, file:]
    end
  end
end
