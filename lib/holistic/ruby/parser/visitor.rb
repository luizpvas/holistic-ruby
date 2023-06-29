# frozen_string_literal: true

module Holistic::Ruby::Parser
  module Visitor
    module Node
      GetNamespadeDeclaration = ->(node) do
        namespace_declaration = NamespaceDeclaration.new

        append = ->(node) do
          case node
          when ::SyntaxTree::ConstRef     then namespace_declaration << node.child_nodes[0].value
          when ::SyntaxTree::Const        then namespace_declaration << node.value
          when ::SyntaxTree::VCall        then namespace_declaration << node.value # not sure what to do here e.g. `described_class::Error`
          when ::SyntaxTree::CallNode     then namespace_declaration << "[dynamic_call]" # not sure what to do here e.g. `::Account.const_get(account.type.classify)::Subscription`
          when ::SyntaxTree::VarRef       then node.child_nodes.each(&append)
          when ::SyntaxTree::ConstPathRef then node.child_nodes.each(&append)
          when ::SyntaxTree::TopConstRef  then namespace_declaration.mark_as_root_scope! and node.child_nodes.each(&append)
          else raise "Unexpected node type: #{node.class}"
          end
        end

        append.(node) and return namespace_declaration
      end

      BuildLocation = ->(node) do
        # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#position
        offset_to_match_language_server_zero_based_position = 1

        ::Holistic::Document::Location.new(
          file_path: Current.file.path,
          start_line: node.location.start_line - offset_to_match_language_server_zero_based_position,
          start_column: node.location.start_column,
          end_line: node.location.end_line - offset_to_match_language_server_zero_based_position,
          end_column: node.location.end_column
        )
      end
    end

    class ProgramVisitor < ::SyntaxTree::Visitor
      visit_methods do
        def visit_module(node)
          declaration, statements = node.child_nodes

          namespace_declaration = Node::GetNamespadeDeclaration[declaration]
          location = Node::BuildLocation[node]

          Current::Namespace.register_child_module(namespace_declaration:, location:) do
            visit(statements)
          end
        end

        def visit_class(node)
          declaration, superclass, statements = node.child_nodes

          if superclass
            superclass_declaration = Node::GetNamespadeDeclaration[superclass]

            if superclass_declaration.root_scope_resolution?
              register_reference(
                name: superclass_declaration.to_s,
                location: Node::BuildLocation[superclass],
                resolution_possibilities: ConstantResolutionPossibilities.root_scope
              )
            else
              register_reference(
                name: superclass_declaration.to_s,
                location: Node::BuildLocation[superclass]
              )
            end
          end

          namespace_declaration = Node::GetNamespadeDeclaration[declaration]
          location = Node::BuildLocation[node]

          Current::Namespace.register_child_class(namespace_declaration:, location:) do
            visit(statements)
          end
        end

        def visit_def(node)
          instance, dot, method_name, _params, body_statement = node.child_nodes

          method_name =
            if instance.present? && dot.present?
              instance.child_nodes.first.value + dot.value + method_name.value
            else
              method_name.value
            end

          method_declaration =
            ::Holistic::Ruby::Namespace::RegisterChildNamespace.call(
              parent: Current.namespace,
              kind: ::Holistic::Ruby::Namespace::Kind::METHOD,
              name: method_name,
              location: Node::BuildLocation.call(node)
            )

          Current.registration_queue.register(method_declaration.to_symbol)

          visit(body_statement)
        end

        def visit_assign(node)
          assign, statement = node.child_nodes

          if !assign.child_nodes.first.is_a?(::SyntaxTree::Const)
            visit(statement)

            return # TODO
          end

          lambda_declaration =
            ::Holistic::Ruby::Namespace::RegisterChildNamespace.call(
              parent: Current.namespace,
              kind: ::Holistic::Ruby::Namespace::Kind::LAMBDA,
              name: assign.child_nodes.first.value,
              location: Node::BuildLocation.call(node)
            )

          Current.registration_queue.register(lambda_declaration.to_symbol)

          visit(statement)
        end

        def visit_const_path_ref(node)
          namespace_declaration = Node::GetNamespadeDeclaration.call(node)

          if namespace_declaration.root_scope_resolution?
            register_reference(
              name: namespace_declaration.to_s,
              location: Node::BuildLocation.call(node),
              resolution_possibilities: ConstantResolutionPossibilities.root_scope
            )
          else
            register_reference(
              name: namespace_declaration.to_s,
              location: Node::BuildLocation.call(node)
            )
          end
        end

        def visit_top_const_ref(node)
          register_reference(
            name: node.child_nodes.first.value,
            location: Node::BuildLocation[node],
            resolution_possibilities: ConstantResolutionPossibilities.root_scope
          )
        end

        def visit_const(node)
          register_reference(name: node.value, location: Node::BuildLocation[node])
        end
      end

      private

      def register_reference(name:, location:, resolution_possibilities: Current.constant_resolution_possibilities.dup)
        clue = ::Holistic::Ruby::TypeInference::Clue::NamespaceReference.new(name:, resolution_possibilities:)

        reference =
          ::Holistic::Ruby::TypeInference::Reference.new(
            namespace: Current.namespace,
            clues: [clue],
            location:
          )

        Current.registration_queue.register(reference.to_symbol)
      end
    end
  end
end
