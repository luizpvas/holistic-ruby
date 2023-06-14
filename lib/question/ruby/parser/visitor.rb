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
          when ::SyntaxTree::VCall        then namespace_declaration << node.value # not sure what to do here e.g. `described_class::Error`
          when ::SyntaxTree::VarRef       then node.child_nodes.each(&append)
          when ::SyntaxTree::ConstPathRef then node.child_nodes.each(&append)
          when ::SyntaxTree::TopConstRef  then namespace_declaration.mark_as_root_scope! and node.child_nodes.each(&append)
          else raise "Unexpected node type: #{node.class}"
          end
        end

        append.(node) and return namespace_declaration
      end

      BuildSourceLocation = ->(node) do
        ::Question::SourceCode::Location.new(
          file_path: Current.file.path,
          start_line: node.location.start_line,
          start_column: node.location.start_column,
          end_line: node.location.end_line,
          end_column: node.location.end_column
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
              register_namespace_reference(
                name: superclass_declaration.to_s,
                source_location: Node::BuildSourceLocation[superclass],
                resolution_possibilities: ConstantResolutionPossibilities.root_scope
              )
            else
              register_namespace_reference(
                name: superclass_declaration.to_s,
                source_location: Node::BuildSourceLocation[superclass]
              )
            end
          end

          namespace_declaration = Node::GetNamespadeDeclaration[declaration]
          source_location = Node::BuildSourceLocation[node]

          Current::Namespace.nest_class(namespace_declaration:, source_location:) do
            visit(statements)
          end
        end

        def visit_assign(node)
          assign, expression = node.child_nodes

          # TODO: do something about assign?

          visit(expression)
        end

        def visit_const_path_ref(node)
          namespace_declaration = Node::GetNamespadeDeclaration.call(node)

          if namespace_declaration.root_scope_resolution?
            register_namespace_reference(
              name: namespace_declaration.to_s,
              source_location: Node::BuildSourceLocation.call(node),
              resolution_possibilities: ConstantResolutionPossibilities.root_scope
            )
          else
            register_namespace_reference(
              name: namespace_declaration.to_s,
              source_location: Node::BuildSourceLocation.call(node)
            )
          end
        end

        def visit_top_const_ref(node)
          register_namespace_reference(
            name: node.child_nodes.first.value,
            source_location: Node::BuildSourceLocation[node],
            resolution_possibilities: ConstantResolutionPossibilities.root_scope
          )
        end

        def visit_const(node)
          register_namespace_reference(name: node.value, source_location: Node::BuildSourceLocation[node])
        end
      end

      private

      def register_namespace_reference(name:, source_location:, resolution_possibilities: Current.constant_resolution_possibilities.dup)
        clue = ::Question::Ruby::TypeInference::Clue::NamespaceReference.new(name:, resolution_possibilities:)

        something = ::Question::Ruby::TypeInference::Something.new(clues: [clue], source_location:)

        Current.registration_queue.register(something.to_symbol)
      end
    end
  end
end
