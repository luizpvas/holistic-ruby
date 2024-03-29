# frozen_string_literal: true

module Holistic::Ruby::TypeInference
  class Resolver
    attr_reader :application

    def initialize(application:)
      @application = application
    end

    def resolve(scope:, bag_of_clues:)
      solve_scope_reference(bag_of_clues:) || solve_method_call(scope:, bag_of_clues:)
    end

    private

    def solve_scope_reference(bag_of_clues:)
      reference_to_scope = bag_of_clues.find(Clue::ScopeReference)

      return if reference_to_scope.nil?
      return if !reference_to_scope.expression.valid?

      Scope.resolve(
        application:,
        expression: reference_to_scope.expression,
        resolution_possibilities: reference_to_scope.resolution_possibilities
      )
    end

    SolveMethodCallInCurrentScope = ->(application:, scope:, method_call_clue:) do
      if scope.class_method?
        ClassMethod.resolve(scope: scope.lexical_parent, method_name: method_call_clue.method_name)
      elsif scope.instance_method? && scope.lexical_parent.present?
        InstanceMethod.resolve(scope: scope.lexical_parent, method_name: method_call_clue.method_name)
      end
    end

    SolveMethodCallInSpecifiedScope = ->(application:, method_call_clue:) do
      referenced_scope = Scope.resolve(
        application:,
        expression: method_call_clue.expression,
        resolution_possibilities: method_call_clue.resolution_possibilities
      )

      return if referenced_scope.nil?

      referenced_method = application.extensions.dispatch(:resolve_method_call_known_scope, { referenced_scope:, method_call_clue: })
      return referenced_method if referenced_method

      ClassMethod.resolve(scope: referenced_scope, method_name: method_call_clue.method_name)
    end

    def solve_method_call(scope:, bag_of_clues:)
      method_call_clue = bag_of_clues.find(Clue::MethodCall)

      return if !method_call_clue
      return if !method_call_clue.expression

      if method_call_clue.expression.namespaces.empty?
        SolveMethodCallInCurrentScope.call(application:, scope:, method_call_clue:)
      else
        SolveMethodCallInSpecifiedScope.call(application:, method_call_clue:)
      end
    end
  end
end
