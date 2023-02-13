# frozen_string_literal: true

module Question::Ruby
  module Parse::Visitor
    DeclarationName = ->(node) do
      parts = []

      case node
      when ::SyntaxTree::ConstRef     then parts << node.child_nodes[0].value
      when ::SyntaxTree::Const        then parts << node.value
      when ::SyntaxTree::ConstPathRef then raise "TODO: ConstPathRef"
      else raise "Unexpected node type: #{node.class}"
      end

      parts.join("::")
    end

    class ProgramVisitor < ::SyntaxTree::Visitor
      visit_methods do
        def visit_module(node)
          declaration, statements = node.child_nodes
          declaration_name = DeclarationName[declaration]

          registry.open_module(declaration_name) { visit(statements) }
        end

        def visit_const(node)
          registry.add_reference!(node.value)
        end
      end

      private

      def registry = Parse::Current.application.constant_registry
    end
  end
end
