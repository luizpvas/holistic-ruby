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
        declaration_node, body_statements_node = node.child_nodes

        expression = Expression::SyntaxTree.build(declaration_node)
        location = build_scope_location(declaration_node:, body_node: node)

        @constant_resolution.register_child_module(expression:, location:) do
          visit(body_statements_node)
        end
      end

      def visit_class(node)
        declaration_node, superclass_node, body_statements_node = node.child_nodes

        expression = Expression::SyntaxTree.build(declaration_node)
        location = build_scope_location(declaration_node:, body_node: node)

        class_scope = @constant_resolution.register_child_class(expression:, location:) do
          visit(body_statements_node)
        end

        if superclass_node
          reference_to_scope_clue = ::Holistic::Ruby::TypeInference::Clue::ScopeReference.new(
            expression: Expression::SyntaxTree.build(superclass_node),
            resolution_possibilities: @constant_resolution.current
          )

          reference_to_superclass_clue = ::Holistic::Ruby::TypeInference::Clue::ReferenceToSuperclass.new(
            subclass_scope: class_scope
          )

          ::Holistic::Ruby::Reference::Store.call(
            database: @application.database,
            processing_queue: @application.type_inference_resolving_queue,
            scope: @constant_resolution.scope,
            clues: [reference_to_scope_clue, reference_to_superclass_clue],
            location: build_location(superclass_node)
          )
        end

        @application.extensions.dispatch(:class_scope_registered, { class_scope:, location: })
      end

      def visit_command(node)
        command_name_node, args_node, block_node = node.child_nodes

        if command_name_node.value == "extend"
          is_extending_self = args_node.child_nodes.size == 1 && Expression::SyntaxTree.build(args_node.child_nodes.first).to_s == "self"

          @constant_resolution.change_method_registration_mode_to_class_methods! if is_extending_self
        end

        if command_name_node.value == "include"
          superclass_expression = Expression::SyntaxTree.build(args_node.child_nodes.first)

          reference_to_scope_clue = ::Holistic::Ruby::TypeInference::Clue::ScopeReference.new(
            expression: superclass_expression,
            resolution_possibilities: @constant_resolution.current
          )

          reference_to_superclass_clue = ::Holistic::Ruby::TypeInference::Clue::ReferenceToSuperclass.new(
            subclass_scope: @constant_resolution.scope
          )

          ::Holistic::Ruby::Reference::Store.call(
            database: @application.database,
            processing_queue: @application.type_inference_resolving_queue,
            scope: @constant_resolution.scope,
            clues: [reference_to_scope_clue, reference_to_superclass_clue],
            location: build_location(node)
          )
        end

        visit(args_node) if args_node
        visit(block_node) if block_node
      end

      def visit_def(node)
        instance_node, period_node, method_name_node, _params, body_statements_node = node.child_nodes

        location = build_scope_location(declaration_node: method_name_node, body_node: node)

        kind =
          if instance_node.present? && instance_node.child_nodes.first.value == "self"
            ::Holistic::Ruby::Scope::Kind::CLASS_METHOD
          elsif @constant_resolution.method_registration_class_methods?
            ::Holistic::Ruby::Scope::Kind::CLASS_METHOD
          else
            ::Holistic::Ruby::Scope::Kind::INSTANCE_METHOD
          end

        method_name = method_name_node.value

        @constant_resolution.register_child_method(method_name:, location:, kind:) do
          visit(body_statements_node)
        end
      end

      def visit_vcall(node)
        expression = Expression::SyntaxTree.build(node)

        method_call_clue = ::Holistic::Ruby::TypeInference::Clue::MethodCall.new(
          expression:,
          method_name: node.child_nodes.first.value,
          resolution_possibilities: @constant_resolution.current
        )

        ::Holistic::Ruby::Reference::Store.call(
          database: @application.database,
          processing_queue: @application.type_inference_resolving_queue,
          scope: @constant_resolution.scope,
          clues: [method_call_clue],
          location: build_location(node)
        )
      end

      def visit_call(node)
        instance_node, _period_node, method_name_node, arguments_nodes = node.child_nodes

        visit(instance_node)
        visit(arguments_nodes)

        expression = Expression::SyntaxTree.build(node)

        return if !expression.valid?

        method_call_clue = ::Holistic::Ruby::TypeInference::Clue::MethodCall.new(
          expression:,
          method_name: expression.methods.first,
          resolution_possibilities: @constant_resolution.current
        )

        ::Holistic::Ruby::Reference::Store.call(
          database: @application.database,
          processing_queue: @application.type_inference_resolving_queue,
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

          expression = Expression::SyntaxTree.build(assign_node)
          location = build_scope_location(declaration_node: assign_node, body_node: block_node)

          class_scope = @constant_resolution.register_child_class(expression:, location:) do
            visit(block_node)
          end

          @application.extensions.dispatch(:class_scope_registered, { class_scope:, location: })

          return
        end

        location = build_scope_location(declaration_node: assign_node, body_node:)

        lambda_scope =
          ::Holistic::Ruby::Scope::Store.call(
            database: @application.database,
            lexical_parent: @constant_resolution.scope,
            kind: ::Holistic::Ruby::Scope::Kind::LAMBDA,
            name: assign_node.child_nodes.first.value,
            location:
          )

        @application.extensions.dispatch(:lambda_scope_registered, { lambda_scope:, location: })

        visit(body_node)
      end

      def visit_const_path_ref(node)
        register_reference(expression: Expression::SyntaxTree.build(node), location: build_location(node))
      end

      def visit_top_const_ref(node)
        register_reference(expression: Expression::SyntaxTree.build(node), location: build_location(node))
      end

      def visit_const(node)
        register_reference(expression: Expression::SyntaxTree.build(node), location: build_location(node))
      end
    end

    private

    def register_reference(expression:, location:)
      clue = ::Holistic::Ruby::TypeInference::Clue::ScopeReference.new(
        expression:,
        resolution_possibilities: @constant_resolution.current
      )

      ::Holistic::Ruby::Reference::Store.call(
        database: @application.database,
        processing_queue: @application.type_inference_resolving_queue,
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

      ::Holistic::Document::Location.new(file:, start_line:, start_column:, end_line:, end_column:)
    end
  end
end
