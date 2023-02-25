# frozen_string_literal: true

module Question::Ruby
  module Parse::Visitor
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

    class ProgramVisitor < ::SyntaxTree::Visitor
      visit_methods do
        def visit_module(node)
          declaration, statements = node.child_nodes
          declaration_name = DeclarationName[declaration]

          repository.open_module(declaration_name) { visit(statements) }
        end

        def visit_const(node)
          repository.add_reference!(node.value)
        end
      end

      private

      def repository = Parse::Current.application.constant_repository
    end
  end
end
