# frozen_string_literal: true

module Question::Ruby::Parser
  module Visitor
    module Node
      GetDeclarationNamePath = ->(node) do
        name_path = NamePath.new

        append = ->(node) do
          case node
          when ::SyntaxTree::ConstRef     then name_path << node.child_nodes[0].value
          when ::SyntaxTree::Const        then name_path << node.value
          when ::SyntaxTree::VarRef       then node.child_nodes.each(&append)
          when ::SyntaxTree::ConstPathRef then node.child_nodes.each(&append)
          else raise "Unexpected node type: #{node.class}"
          end
        end

        append.(node) and return name_path
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

          name_path = Node::GetDeclarationNamePath[declaration]
          source_location = Node::BuildSourceLocation[node]

          Current::Namespace.nest_module(name_path:, source_location:) do
            visit(statements)
          end
        end

        def visit_class(node)
          declaration, superclass, statements = node.child_nodes

          if superclass
            superclass_name_path = Node::GetDeclarationNamePath[superclass]

            add_reference!(superclass_name_path.to_s)
          end

          name_path = Node::GetDeclarationNamePath[declaration]
          source_location = Node::BuildSourceLocation[node]

          Current::Namespace.nest_class(name_path:, source_location:) do
            visit(statements)
          end
        end

        def visit_const(node)
          add_reference!(node.value)
        end
      end

      private

      def add_reference!(name)
        Current.application.references.add(resolution: Current.resolution.dup, name:)
      end
    end
  end
end
