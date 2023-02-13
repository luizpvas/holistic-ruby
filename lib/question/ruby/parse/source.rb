# frozen_string_literal: true

module Question::Ruby::Parse
  Source = ->(source:, application:) do
    program = ::SyntaxTree.parse(source)

    Current.application = application

    Visitor::ProgramVisitor.new.visit(program)
  end
end
