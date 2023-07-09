# frozen_string_literal: true

module Holistic::Ruby::TypeInference
  module Solve
    extend self

    def call(application:, reference:)
      solved = solve_scope_reference(application:, reference:)

      reference.conclusion.status = STATUS_DONE

      application.references.register_reference(reference)
    end

    private

    def solve_scope_reference(application:, reference:)
      has_scope_reference_clue =
        reference.clues.one? && reference.clues.first.is_a?(Clue::ScopeReference)

      return unless has_scope_reference_clue

      reference_clue = reference.clues.first

      reference_clue.resolution_possibilities.each do |resolution_candidate|
        fully_qualified_scope_name =
          if resolution_candidate == "::"
            "::#{reference_clue.name}"
          else
            "#{resolution_candidate}::#{reference_clue.name}"
          end

        referenced_scope = application.scopes.find_by_fully_qualified_name(fully_qualified_scope_name)

        if referenced_scope.present?
          application.dependencies.register(dependency: referenced_scope, reference_identifier: reference.identifier)

          reference.conclusion.dependency_identifier = fully_qualified_scope_name

          return true
        end
      end
    end
  end
end
