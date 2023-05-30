# frozen_string_literal: true

module Question::Ruby::Parser
  module Visitor
    module Node
      GetNamespadeDeclaration = ->(node) do
        namespace_declaration = NamespaceDeclaration.new

        append = ->(node) do
          case node
          when ::SyntaxTree::ConstRef     then namespace_declaration << node.child_nodes[0].value
          when ::SyntaxTree::Const        then namespace_declaration << node.value
          when ::SyntaxTree::VarRef       then node.child_nodes.each(&append)
          when ::SyntaxTree::ConstPathRef then node.child_nodes.each(&append)
          when ::SyntaxTree::TopConstRef  then namespace_declaration.mark_as_top_const_ref! and node.child_nodes.each(&append)
          else raise "Unexpected node type: #{node.class}"
          end
        end

        append.(node) and return namespace_declaration
      end

      BuildSourceLocation = ->(node) do
        ::Question::SourceCode::Location.new(
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

          namespace_declaration = Node::GetNamespadeDeclaration[declaration]
          source_location = Node::BuildSourceLocation[node]

          Current::Namespace.nest_module(namespace_declaration:, source_location:) do
            visit(statements)
          end
        end

        def visit_class(node)
          declaration, superclass, statements = node.child_nodes

          if superclass
            superclass_declaration = Node::GetNamespadeDeclaration[superclass]

            if superclass_declaration.root_scope_resolution?
              add_reference!(name: superclass_declaration.to_s, resolution: [])
            else
              add_reference!(name: superclass_declaration.to_s)
            end
          end

          namespace_declaration = Node::GetNamespadeDeclaration[declaration]
          source_location = Node::BuildSourceLocation[node]

          Current::Namespace.nest_class(namespace_declaration:, source_location:) do
            visit(statements)
          end
        end

        def visit_const(node)
          add_reference!(name: node.value)
        end
      end

      private

      def add_reference!(name:, resolution: Current.resolution.dup)
        Current.application.references.add(name:, resolution:)
      end
    end
  end
end
