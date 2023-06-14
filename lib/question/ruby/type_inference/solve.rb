# frozen_string_literal: true

module Question::Ruby::TypeInference
  module Solve
    extend self

    def call(application:, something:)
      solve_namespace_reference(application:, something:)
    end

    private

    RegisterTypeInferenceDependency = ->(application:, something:, dependency:) do
      # TODO: try to guess the main source location. Perhaps based on the file name?
      dependency_source_location = dependency.source_locations.first

      dependency_and_dependant_are_declared_in_the_same_file =
        dependency_source_location.file_path == something.source_location.file_path

      return if dependency_and_dependant_are_declared_in_the_same_file

      application.dependencies.register(
        dependency_file_path: dependency_source_location.file_path,
        dependant_identifier: something.identifier
      )
    end

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
          RegisterTypeInferenceDependency.call(application:, something:, dependency:)

          something.conclusion = Conclusion.with_strong_confidence(dependency.identifier)

          return true
        end
      end
    end
  end
end
