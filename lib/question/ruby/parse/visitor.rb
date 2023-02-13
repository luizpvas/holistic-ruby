# frozen_string_literal: true

module Question::Ruby
  module Parse::Visitor
    DeclarationName = ->(node) do
      parts = []

      case node
      when ::SyntaxTree::ConstRef then parts << node.child_nodes[0].value
      when ::SyntaxTree::Const    then parts << node.value
      else raise "Unexpected node type: #{node.class}"
      end

      parts.join("::")
    end

    IsAssignToConst = ->(node) do
      node.is_a?(::SyntaxTree::VarField) && node.child_nodes[0].is_a?(::SyntaxTree::Const)
    end

    class ProgramVisitor < ::SyntaxTree::Visitor
      visit_methods do
        def visit_module(node)
          declaration, body = node.child_nodes

          Parse::Current.application.constant_registry.open! do |namespace|
            Constant::Namespace::Module.new(parent_namespace: namespace, name: DeclarationName[declaration])
          end

          super

          Parse::Current.application.constant_registry.close!
        end
      end
    end
  end
end
