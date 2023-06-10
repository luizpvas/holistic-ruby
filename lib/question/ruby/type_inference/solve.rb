# frozen_string_literal: true

module Question::Ruby::TypeInference
  module Solve
    extend self

    def call(application:, something:)
      solve_namespace_reference(application:, something:)
    end

    private

    def solve_namespace_reference(application:, something:)
      has_namespace_reference_clue =
        something.clues.one? && something.clues.first.is_a?(Clue::NamespaceReference)

      return unless has_namespace_reference_clue

      namespace_reference = something.clues.first

      namespace_reference.resolution.each do |resolution_candidate|
        target_identifier = "::#{resolution_candidate}::#{namespace_reference.name}"

        target = application.symbol_index.find(target_identifier)

        if target.present?
          something.conclusion = Conclusion.with_strong_confidence(target)
        end
      end
    end
  end
end
