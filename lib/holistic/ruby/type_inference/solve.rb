# frozen_string_literal: true

module Holistic::Ruby::TypeInference
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

      namespace_reference.resolution_possibilities.each do |resolution_candidate|
        dependency_identifier =
          if resolution_candidate == "::"
            "::#{namespace_reference.name}"
          else
            "#{resolution_candidate}::#{namespace_reference.name}"
          end

        dependency = application.symbols.find(dependency_identifier)

        if dependency.present?
          application.dependencies.register(dependency:, dependant_identifier: something.identifier)

          something.conclusion = Conclusion.with_strong_confidence(dependency.identifier)

          return true
        end
      end
    end
  end
end
