# frozen_string_literal: true

module Question::Ruby::Parser
  ParseCode = ->(application:, code:) do
    namespace = application.root_namespace
    constant_resolution_possibilities = ConstantResolutionPossibilities.root_scope

    Current.set(application:, namespace:, constant_resolution_possibilities:) do
      program = ::SyntaxTree.parse(code)

      Visitor::ProgramVisitor.new.visit(program)
    end
  end

  ParseFile = ->(application:, file:) do
    application.files.register_parsed_file(file)

    Current.set(file:) do
      ParseCode[application:, code: file.read]
    end
  end

  ParseDirectory = ->(application:, directory_path:) do
    ::Dir.glob("#{directory_path}/**/*.rb").map do |file_path|
      file = ::Question::File::Disk.new(path: file_path)

      ParseFile[application:, file:]
    end
  end

  # TODO: find a better name or a better abstraction
  WrapParsingUnitWithProcessAtTheEnd = ->(application:, &block) do
    registration_queue = Current::RegistrationQueue.new(application:)

    Current.set(registration_queue:, &block)

    registration_queue.process
  end
end
