# frozen_string_literal: true

module Holistic::Ruby::Parser
  class ProgramVisitor < ::SyntaxTree::Visitor
    attr_reader :application, :file

    def initialize(application:, constant_resolution:, file:)
      @application = application
      @constant_resolution = constant_resolution
      @file = file

      super()
    end

    visit_methods do
      def visit_module(node)
        declaration_node, statements_nodes = node.child_nodes

        nesting = Node::BuildNestingSyntax[declaration_node]
        location = build_location(declaration_node)

        @constant_resolution.register_child_module(nesting:, location:) do
          visit(statements_nodes)
        end
      end

      def visit_class(node)
        declaration_node, superclass_node, statements_nodes = node.child_nodes

        if superclass_node
          register_reference(nesting: Node::BuildNestingSyntax[superclass_node], location: build_location(superclass_node))
        end

        nesting = Node::BuildNestingSyntax[declaration_node]
        location = build_location(declaration_node)

        @constant_resolution.register_child_class(nesting:, location:) do
          visit(statements_nodes)
        end
      end

      def visit_def(node)
        instance_node, period_node, method_name_node, _params, statements_nodes = node.child_nodes

        method_name =
          if instance_node.present? && period_node.present?
            instance_node.child_nodes.first.value + period_node.value + method_name_node.value
          else
            method_name_node.value
          end

        ::Holistic::Ruby::Scope::Register.call(
          repository: @application.scopes,
          parent: @constant_resolution.scope,
          kind: ::Holistic::Ruby::Scope::Kind::METHOD,
          name: method_name,
          location: build_location(node)
        )

        visit(statements_nodes)
      end

      def visit_call(node)
        instance_node, _period_node, method_name_node, arguments_nodes = node.child_nodes

        visit(instance_node)
        visit(arguments_nodes)

        # NOTE: I have a feeling this is incomplete. Need to add more specs.
        nesting =
          if instance_node.is_a?(::SyntaxTree::CallNode)
            Node::BuildNestingSyntax.call(instance_node.child_nodes[2])
          else
            Node::BuildNestingSyntax.call(instance_node)
          end

        return if nesting.unsupported?

        # This method_name_node is nil when using the syntax `DoSomething.(value)`
        method_name = method_name_node.nil? ? "call" : method_name_node.value
        
        method_call_clue = ::Holistic::Ruby::TypeInference::Clue::MethodCall.new(
          nesting:,
          method_name:,
          resolution_possibilities: @constant_resolution.current
        )

        ::Holistic::Ruby::Reference::Register.call(
          repository: @application.references,
          scope: @constant_resolution.scope,
          clues: [method_call_clue],
          location: build_location(method_name_node || instance_node)
        )
      end

      def visit_assign(node)
        assign_node, statement_node = node.child_nodes

        if !assign_node.child_nodes.first.is_a?(::SyntaxTree::Const)
          visit(statement_node)

          return # TODO
        end

        # Are we assigning to something that opens a block? If so, we need to register the child scope
        # and visit the statements. This is needed to support methods defined in `Data.define` and `Struct.new`.
        if statement_node.is_a?(::SyntaxTree::MethodAddBlock)
          call_node, block_node = statement_node.child_nodes

          nesting = Node::BuildNestingSyntax[assign_node]
          location = build_location(assign_node)

          @constant_resolution.register_child_class(nesting:, location:) do
            visit(block_node)
          end

          return
        end

        ::Holistic::Ruby::Scope::Register.call(
          repository: @application.scopes,
          parent: @constant_resolution.scope,
          kind: ::Holistic::Ruby::Scope::Kind::LAMBDA,
          name: assign_node.child_nodes.first.value,
          location: build_location(node)
        )

        visit(statement_node)
      end

      def visit_const_path_ref(node)
        register_reference(nesting: Node::BuildNestingSyntax[node], location: build_location(node))
      end

      def visit_top_const_ref(node)
        register_reference(nesting: Node::BuildNestingSyntax[node], location: build_location(node))
      end

      def visit_const(node)
        register_reference(nesting: Node::BuildNestingSyntax[node], location: build_location(node))
      end
    end

    private

    def register_reference(nesting:, location:)
      clue = ::Holistic::Ruby::TypeInference::Clue::ScopeReference.new(
        nesting:,
        resolution_possibilities: @constant_resolution.current
      )

      ::Holistic::Ruby::Reference::Register.call(
        repository: @application.references,
        scope: @constant_resolution.scope,
        clues: [clue],
        location:
      )
    end

    def build_location(node)
      # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#position
      offset_to_match_language_server_zero_based_position = 1

      ::Holistic::Document::Location.new(
        file_path: file.path,
        start_line: node.location.start_line - offset_to_match_language_server_zero_based_position,
        start_column: node.location.start_column,
        end_line: node.location.end_line - offset_to_match_language_server_zero_based_position,
        end_column: node.location.end_column
      )
    end
  end
end
