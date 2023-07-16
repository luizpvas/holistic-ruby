# frozen_string_literal: true

module Holistic::Ruby::Parser
  module Visitor
    module Node
      BuildNestingSyntax = ->(node) do
        original_node = node
        nesting_syntax = NestingSyntax.new

        append = ->(node) do
          case node
          when ::SyntaxTree::ConstRef     then nesting_syntax << node.child_nodes[0].value
          when ::SyntaxTree::Const        then nesting_syntax << node.value
          when ::SyntaxTree::VCall        then nesting_syntax << node.value
          when ::SyntaxTree::Ident        then nesting_syntax << node.value
          when ::SyntaxTree::IVar         then nesting_syntax << node.value
          when ::SyntaxTree::Paren        then append.(node.child_nodes[1])       # node.child_nodes[0] is ::SyntaxTree::LParen
          when ::SyntaxTree::ARef         then append.(node.child_nodes.first)    # not sure what to do here e.g. `ActiveRecord::Migration[7.0]`
          when ::SyntaxTree::CallNode     then nesting_syntax << "[dynamic_call]" # not sure what to do here e.g. `::Account.const_get(account.type.classify)::Subscription`
          when ::SyntaxTree::IfOp         then nesting_syntax << "[conditional]"  # not sure what tod o here
          when ::SyntaxTree::VarRef       then node.child_nodes.each(&append)
          when ::SyntaxTree::ConstPathRef then node.child_nodes.each(&append)
          when ::SyntaxTree::Statements   then node.child_nodes.each(&append)
          when ::SyntaxTree::TopConstRef  then nesting_syntax.mark_as_root_scope! and node.child_nodes.each(&append)
          else pp(original_node) and raise "Unexpected node type: #{node.class}"
          end
        end

        append.(node) and return nesting_syntax
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

          nesting = Node::BuildNestingSyntax[declaration]
          location = Node::BuildLocation[declaration]

          Current::Scope.register_child_module(nesting:, location:) do
            visit(statements)
          end
        end

        def visit_class(node)
          declaration, superclass, statements = node.child_nodes

          if superclass
            superclass_nesting = Node::BuildNestingSyntax[superclass]

            if superclass_nesting.root_scope_resolution?
              register_reference(
                name: superclass_nesting.to_s,
                location: Node::BuildLocation[superclass],
                resolution_possibilities: ConstantResolutionPossibilities.root_scope
              )
            else
              register_reference(
                name: superclass_nesting.to_s,
                location: Node::BuildLocation[superclass]
              )
            end
          end

          nesting = Node::BuildNestingSyntax[declaration]
          location = Node::BuildLocation[declaration]

          Current::Scope.register_child_class(nesting:, location:) do
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

          ::Holistic::Ruby::Scope::Register.call(
            repository: Current.application.scopes,
            parent: Current.scope,
            kind: ::Holistic::Ruby::Scope::Kind::METHOD,
            name: method_name,
            location: Node::BuildLocation.call(node)
          )

          visit(body_statement)
        end

        def visit_assign(node)
          assign, statement = node.child_nodes

          if !assign.child_nodes.first.is_a?(::SyntaxTree::Const)
            visit(statement)

            return # TODO
          end

          ::Holistic::Ruby::Scope::Register.call(
            repository: Current.application.scopes,
            parent: Current.scope,
            kind: ::Holistic::Ruby::Scope::Kind::LAMBDA,
            name: assign.child_nodes.first.value,
            location: Node::BuildLocation.call(node)
          )

          visit(statement)
        end

        def visit_const_path_ref(node)
          nesting = Node::BuildNestingSyntax.call(node)

          if nesting.root_scope_resolution?
            register_reference(
              name: nesting.to_s,
              location: Node::BuildLocation.call(node),
              resolution_possibilities: ConstantResolutionPossibilities.root_scope
            )
          else
            register_reference(
              name: nesting.to_s,
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
        clue = ::Holistic::Ruby::TypeInference::Clue::ScopeReference.new(name:, resolution_possibilities:)

        ::Holistic::Ruby::Reference::Register.call(
          repository: Current.application.references,
          scope: Current.scope,
          clues: [clue],
          location:
        )
      end
    end
  end
end
