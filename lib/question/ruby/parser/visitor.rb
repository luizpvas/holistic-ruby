# frozen_string_literal: true

module Question::Ruby::Parser
  module Visitor
    module Node
      GetDeclarationName = ->(node) do
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
          file_path: Current.file_path,
          start_line: node.location.start_line,
          end_line: node.location.end_line
        )
      end
    end

    class ProgramVisitor < ::SyntaxTree::Visitor
      visit_methods do
        def visit_module(node)
          declaration, statements = node.child_nodes
          declaration_name = Node::GetDeclarationName[declaration]

          source_location = Node::BuildSourceLocation.call(node)

          Current::Namespace.nest_module(name: declaration_name, source_location:) do
            visit(statements)
          end
        end

        def visit_class(node)
          declaration, superclass, statements = node.child_nodes

          if superclass
            add_reference!(Node::GetDeclarationName[superclass])
          end

          declaration_name = Node::GetDeclarationName[declaration]
          source_location = Node::BuildSourceLocation.call(node)

          Current::Namespace.nest_class(name: declaration_name, source_location:) do
            visit(statements)
          end
        end

        def visit_const(node)
          add_reference!(node.value)
        end
      end

      private

      def add_reference!(name) = Current.application.repository.references.add(namespace: Current.namespace, name:)
    end
  end
end
