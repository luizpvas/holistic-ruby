# frozen_string_literal: true

module Holistic::Ruby::TypeInference
  module Solve
    extend self

    def call(application:, reference:)
      referenced_scope =
        solve_scope_reference(application:, reference:) ||
        solve_method_call(application:, reference:)

      if referenced_scope
        reference.relation(:referenced_scope).add!(referenced_scope)
      end
    end

    private

    def solve_scope_reference(application:, reference:)
      has_scope_reference_clue =
        reference.clues.one? && reference.clues.first.is_a?(Clue::ScopeReference)

      return unless has_scope_reference_clue

      scope_reference_clue = reference.clues.first

      resolve_scope(
        application:,
        nesting: scope_reference_clue.nesting,
        resolution_possibilities: scope_reference_clue.resolution_possibilities
      )
    end

    SolveMethodCallInCurrentScope = ->(application:, reference:, method_call_clue:) do
      scope = reference.located_in_scope

      if scope.class_method?
        resolve_class_method(application:, scope: scope.lexical_parent, method_name: method_call_clue.method_name)
      elsif scope.instance_method? && scope.lexical_parent.present?
        resolve_instance_method(application:, scope: scope.lexical_parent, method_name: method_call_clue.method_name)
      end
    end

    SolveMethodCallInSpecifiedScope = ->(application:, reference:, method_call_clue:) do
      referenced_scope = resolve_scope(
        application:,
        nesting: method_call_clue.nesting,
        resolution_possibilities: method_call_clue.resolution_possibilities
      )

      return if referenced_scope.nil?

      referenced_method = application.extensions.dispatch(:resolve_method_call_known_scope, { reference:, referenced_scope:, method_call_clue: })

      referenced_method || resolve_class_method(application:, scope: referenced_scope, method_name: method_call_clue.method_name)
    end

    SolveMethodCallInLocalVariable = ->(application:, reference:, method_call_clue:) do
      # local_variable_name = method_call_clue.nesting.to_s
      # referenced_scope = guess_scope_for_local_variable(scope: reference.scope, name: local_variable_name)

      nil
    end

    def solve_method_call(application:, reference:)
      has_method_call_clue = reference.clues.one? && reference.clues.first.is_a?(Clue::MethodCall)

      return unless has_method_call_clue

      method_call_clue = reference.clues.first

      if method_call_clue.nesting.nil?
        SolveMethodCallInCurrentScope.call(application:, reference:, method_call_clue:)
      elsif method_call_clue.nesting.constant?
        SolveMethodCallInSpecifiedScope.call(application:, reference:, method_call_clue:)
      else
        SolveMethodCallInLocalVariable.call(application:, reference:, method_call_clue:)
      end
    end

    def resolve_scope(application:, nesting:, resolution_possibilities:)
      resolution_possibilities = ["::"] if nesting.root_scope_resolution?

      resolution_possibilities.each do |resolution_candidate|
        fully_qualified_scope_name =
          if resolution_candidate == "::"
            "::#{nesting.to_s}"
          else
            "#{resolution_candidate}::#{nesting.to_s}"
          end

        scope = application.scopes.find(fully_qualified_scope_name)

        return scope if scope.present?
      end

      nil
    end

    def resolve_instance_method(application:, scope:, method_name:)
      method_fully_qualified_name = "#{scope.fully_qualified_name}##{method_name}"

      application.scopes.find(method_fully_qualified_name)
    end

    def resolve_class_method(application:, scope:, method_name:)
      method_fully_qualified_name = "#{scope.fully_qualified_name}.#{method_name}"

      application.scopes.find(method_fully_qualified_name)
    end
  end
end
