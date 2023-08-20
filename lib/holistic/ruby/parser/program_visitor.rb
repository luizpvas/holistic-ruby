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
        declaration_node, body_node = node.child_nodes

        nesting = NestingSyntax.build(declaration_node)
        location = build_scope_location(declaration_node:, body_node:)

        @constant_resolution.register_child_module(nesting:, location:) do
          visit(body_node)
        end
      end

      def visit_class(node)
        declaration_node, superclass_node, body_node = node.child_nodes

        if superclass_node
          register_reference(nesting: NestingSyntax.build(superclass_node), location: build_location(superclass_node))
        end

        nesting = NestingSyntax.build(declaration_node)
        location = build_scope_location(declaration_node:, body_node:)

        class_scope = @constant_resolution.register_child_class(nesting:, location:) do
          visit(body_node)
        end

        @application.extensions.dispatch(:class_scope_registered, { class_scope:, location: })
      end

      def visit_command(node)
        command_name_node, args_node = node.child_nodes

        if command_name_node.value == "extend"
          is_extending_self = args_node.child_nodes.size == 1 && NestingSyntax.build(args_node.child_nodes.first).to_s == "self"

          @constant_resolution.change_method_registration_mode_to_class_methods! if is_extending_self
        end

        visit(args_node)
      end

      def visit_def(node)
        instance_node, period_node, method_name_node, _params, body_node = node.child_nodes

        nesting = NestingSyntax.new(method_name_node.value)
        location = build_scope_location(declaration_node: method_name_node, body_node:)

        kind =
          if instance_node.present? && instance_node.child_nodes.first.value == "self"
            ::Holistic::Ruby::Scope::Kind::CLASS_METHOD
          elsif @constant_resolution.method_registration_class_methods?
            ::Holistic::Ruby::Scope::Kind::CLASS_METHOD
          else
            ::Holistic::Ruby::Scope::Kind::INSTANCE_METHOD
          end

        @constant_resolution.register_child_method(nesting:, location:, kind:) do
          visit(body_node)
        end
      end

      def visit_vcall(node)
        method_call_clue = ::Holistic::Ruby::TypeInference::Clue::MethodCall.new(
          nesting: nil,
          method_name: node.child_nodes.first.value,
          resolution_possibilities: @constant_resolution.current
        )

        ::Holistic::Ruby::Reference::Register.call(
          repository: @application.references,
          scope: @constant_resolution.scope,
          clues: [method_call_clue],
          location: build_location(node)
        )
      end

      def visit_call(node)
        instance_node, _period_node, method_name_node, arguments_nodes = node.child_nodes

        visit(instance_node)
        visit(arguments_nodes)

        nesting =
          if instance_node.is_a?(::SyntaxTree::CallNode)
            NestingSyntax.build(instance_node.child_nodes[2])
          elsif instance_node.present?
            NestingSyntax.build(instance_node)
          else
            nil
          end

        return if nesting.present? && nesting.unsupported?

        # method_name_node is nil for the syntax `DoSomething.(value)`
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
        assign_node, body_node = node.child_nodes

        if !assign_node.child_nodes.first.is_a?(::SyntaxTree::Const)
          visit(body_node)

          return # TODO
        end

        # Are we assigning to something that opens a block? If so, we need to register the child scope
        # and visit the statements. This is needed to support methods defined in `Data.define` and `Struct.new`.
        if body_node.is_a?(::SyntaxTree::MethodAddBlock)
          call_node, block_node = body_node.child_nodes

          nesting = NestingSyntax.build(assign_node)
          location = build_scope_location(declaration_node: assign_node, body_node: block_node)

          class_scope = @constant_resolution.register_child_class(nesting:, location:) do
            visit(block_node)
          end

          @application.extensions.dispatch(:class_scope_registered, { class_scope:, location: })

          return
        end

        location = build_scope_location(declaration_node: assign_node, body_node:)

        lambda_scope =
          ::Holistic::Ruby::Scope::Register.call(
            repository: @application.scopes,
            parent: @constant_resolution.scope,
            kind: ::Holistic::Ruby::Scope::Kind::LAMBDA,
            name: assign_node.child_nodes.first.value,
            location:
          )

        @application.extensions.dispatch(:lambda_scope_registered, { lambda_scope:, location: })

        visit(body_node)
      end

      def visit_const_path_ref(node)
        register_reference(nesting: NestingSyntax.build(node), location: build_location(node))
      end

      def visit_top_const_ref(node)
        register_reference(nesting: NestingSyntax.build(node), location: build_location(node))
      end

      def visit_const(node)
        register_reference(nesting: NestingSyntax.build(node), location: build_location(node))
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

    def build_scope_location(declaration_node:, body_node:)
      ::Holistic::Ruby::Scope::Location.new(
        declaration: build_location(declaration_node),
        body: build_location(body_node)
      )
    end

    def build_location(node)
      # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#position
      offset_to_match_language_server_zero_based_position = 1

      start_line   = node.location.start_line - offset_to_match_language_server_zero_based_position
      end_line     = node.location.end_line - offset_to_match_language_server_zero_based_position
      start_column = node.location.start_column
      end_column   = node.location.end_column

      # syntax_tree seems to have a bug with the bodystmt node.
      # It sets the end_column lower than the start_column.
      if start_line == end_line && start_column > end_column
        start_column, end_column = end_column, start_column
      end

      ::Holistic::Document::Location.new(file_path: file.path, start_line:, start_column:, end_line:, end_column:)
    end
  end
end
