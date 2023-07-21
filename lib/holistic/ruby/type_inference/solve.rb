# frozen_string_literal: true

module Holistic::Ruby::TypeInference
  module Solve
    extend self

    def call(application:, reference:)
      conclusion = solve_scope_reference(application:, reference:)

      reference.conclusion = conclusion || Conclusion.unresolved

      application.references.register_reference(reference)
    end

    private

    def solve_scope_reference(application:, reference:)
      has_scope_reference_clue =
        reference.clues.one? && reference.clues.first.is_a?(Clue::ScopeReference)

      return unless has_scope_reference_clue

      scope_reference = reference.clues.first

      resolution_possibilities =
        if scope_reference.nesting.root_scope_resolution?
          ["::"]
        else
          scope_reference.resolution_possibilities
        end

      resolution_possibilities.each do |resolution_candidate|
        fully_qualified_scope_name =
          if resolution_candidate == "::"
            "::#{scope_reference.nesting.to_s}"
          else
            "#{resolution_candidate}::#{scope_reference.nesting.to_s}"
          end

        referenced_scope = application.scopes.find_by_fully_qualified_name(fully_qualified_scope_name)

        if referenced_scope.present?
          return Conclusion.done(fully_qualified_scope_name)
        end
      end

      nil
    end
  end
end
