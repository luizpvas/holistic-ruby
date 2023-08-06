# frozen_string_literal: true

module Holistic::Ruby::TypeInference
  module Solve
    extend self

    def call(application:, reference:)
      reference.conclusion =
        solve_scope_reference(application:, reference:) ||
        solve_method_call(application:, reference:) ||
        Conclusion.unresolved

      application.references.register_reference(reference)
    end

    private

    def solve_scope_reference(application:, reference:)
      has_scope_reference_clue =
        reference.clues.one? && reference.clues.first.is_a?(Clue::ScopeReference)

      return unless has_scope_reference_clue

      scope_reference_clue = reference.clues.first

      referenced_scope = resolve_scope(
        application:,
        nesting: scope_reference_clue.nesting,
        resolution_possibilities: scope_reference_clue.resolution_possibilities
      )

      if referenced_scope.present?
        return Conclusion.done(referenced_scope.fully_qualified_name)
      end

      nil
    end

    def solve_method_call(application:, reference:)
      has_method_call_clue = reference.clues.one? && reference.clues.first.is_a?(Clue::MethodCall)

      return unless has_method_call_clue

      method_call_clue = reference.clues.first

      if method_call_clue.nesting.present?
        if method_call_clue.nesting.constant?
          referenced_scope = resolve_scope(
            application:,
            nesting: method_call_clue.nesting,
            resolution_possibilities: method_call_clue.resolution_possibilities
          )

          return if referenced_scope.nil?

          referenced_method = resolve_method(application:, scope: referenced_scope, method_name: method_call_clue.method_name)
          referenced_method ||= application.extensions.dispatch(:resolve_method_call_known_scope, { reference:, referenced_scope:, method_call_clue: })

          return Conclusion.done(referenced_method.fully_qualified_name) if referenced_method.present?
        end
      else
        referenced_method = resolve_method(application:, scope: reference.scope, method_name: method_call_clue.method_name)

        return Conclusion.done(referenced_method.fully_qualified_name) if referenced_method.present?
      end

      nil
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

        scope = application.scopes.find_by_fully_qualified_name(fully_qualified_scope_name)

        return scope if scope.present?
      end

      nil
    end

    def resolve_method(application:, scope:, method_name:)
      method_fully_qualified_name = "#{scope.fully_qualified_name}##{method_name}"

      application.scopes.find_by_fully_qualified_name(method_fully_qualified_name)
    end
  end
end
