# frozen_string_literal: true

module Holistic::Ruby::TypeInference
  module Solve
    extend self

    def call(application:, reference:)
      solve_scope_reference(application:, reference:)
    end

    private

    def solve_scope_reference(application:, reference:)
      has_scope_reference_clue =
        reference.clues.one? && reference.clues.first.is_a?(Clue::ScopeReference)

      return unless has_scope_reference_clue

      scope_reference = reference.clues.first

      scope_reference.resolution_possibilities.each do |resolution_candidate|
        dependency_identifier =
          if resolution_candidate == "::"
            "::#{scope_reference.name}"
          else
            "#{resolution_candidate}::#{scope_reference.name}"
          end

        dependency = application.symbols.find(dependency_identifier)

        if dependency.present?
          application.dependencies.register(dependency:, reference_identifier: reference.identifier)

          reference.conclusion = Conclusion.with_strong_confidence(dependency.identifier)

          return true
        end
      end
    end
  end
end
