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

        # NOTE: should this be an event that is handled by stdlib? I guess inheritance support with dedicated syntax
        # is part of the language core, so it makes sense being here. Let me think about this for a bit.
        reference.find_clue(Clue::ReferenceToSuperclass)&.then do |reference_to_superclass_clue|
          referenced_scope.relation(:descendants).add!(reference_to_superclass_clue.subclass_scope)
        end
      end
    end

    private

    def solve_scope_reference(application:, reference:)
      reference_to_scope_clue = reference.find_clue(Clue::ScopeReference)

      return if reference_to_scope_clue.nil?

      Solver::Scope.solve(
        application:,
        nesting: reference_to_scope_clue.nesting,
        resolution_possibilities: reference_to_scope_clue.resolution_possibilities
      )
    end

    SolveMethodCallInCurrentScope = ->(application:, reference:, method_call_clue:) do
      scope = reference.located_in_scope

      if scope.class_method?
        Solver::ClassMethod.solve(application:, scope: scope.lexical_parent, method_name: method_call_clue.method_name)
      elsif scope.instance_method? && scope.lexical_parent.present?
        Solver::InstanceMethod.solve(application:, scope: scope.lexical_parent, method_name: method_call_clue.method_name)
      end
    end

    SolveMethodCallInSpecifiedScope = ->(application:, reference:, method_call_clue:) do
      referenced_scope = Solver::Scope.solve(
        application:,
        nesting: method_call_clue.nesting,
        resolution_possibilities: method_call_clue.resolution_possibilities
      )

      return if referenced_scope.nil?

      referenced_method = application.extensions.dispatch(:resolve_method_call_known_scope, { reference:, referenced_scope:, method_call_clue: })

      referenced_method || Solver::ClassMethod.solve(application:, scope: referenced_scope, method_name: method_call_clue.method_name)
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
        nil # TODO
      end
    end
  end
end
