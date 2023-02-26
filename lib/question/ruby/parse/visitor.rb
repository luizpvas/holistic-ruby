# frozen_string_literal: true

module Question::Ruby::Parse
  module Visitor
    DeclarationName = ->(node) do
      parts = []

      append = ->(node) do
        case node
        when ::SyntaxTree::ConstRef     then parts << node.child_nodes[0].value
        when ::SyntaxTree::Const        then parts << node.value
        when ::SyntaxTree::VarRef       then node.child_nodes.each(&append)
        when ::SyntaxTree::ConstPathRef then node.child_nodes.each(&append)
        else raise "Unexpected node type: #{node.class}"
        end
      end

      append.(node) and parts.join("::")
    end

    BuildSourceLocation = ->(node) do
      ::Question::Ruby::SourceLocation.new(
        file_path: nil,
        start_line: node.location.start_line,
        end_line: node.location.end_line
      )
    end

    class ProgramVisitor < ::SyntaxTree::Visitor
      visit_methods do
        def visit_module(node)
          declaration, statements = node.child_nodes
          declaration_name = DeclarationName[declaration]

          source_location = BuildSourceLocation.call(node)

          repository.open_module(name: declaration_name, source_location:) { visit(statements) }
        end

        def visit_class(node)
          declaration, _superclass, statements = node.child_nodes
          declaration_name = DeclarationName[declaration]

          source_location = BuildSourceLocation.call(node)

          repository.open_class(name: declaration_name, source_location:) { visit(statements) }
        end

        def visit_const(node)
          repository.add_reference!(node.value)
        end
      end

      private

      def repository = Current.application.repository
    end
  end
end
