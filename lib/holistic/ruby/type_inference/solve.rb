# frozen_string_literal: true

module Holistic::Ruby::TypeInference
  module Solve
    extend self

    def call(application:, reference:)
      solve_namespace_reference(application:, reference:)
    end

    private

    def solve_namespace_reference(application:, reference:)
      has_namespace_reference_clue =
        reference.clues.one? && reference.clues.first.is_a?(Clue::NamespaceReference)

      return unless has_namespace_reference_clue

      namespace_reference = reference.clues.first

      namespace_reference.resolution_possibilities.each do |resolution_candidate|
        dependency_identifier =
          if resolution_candidate == "::"
            "::#{namespace_reference.name}"
          else
            "#{resolution_candidate}::#{namespace_reference.name}"
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
