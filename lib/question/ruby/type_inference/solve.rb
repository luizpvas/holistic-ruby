# frozen_string_literal: true

module Question::Ruby::TypeInference
  module Solve
    extend self

    def call(application:, something:)
      solve_namespace_reference(application:, something:)
    end

    private

    RegisterTypeInferenceDependency = ->(application:, something:, target:) do
      raise "TODO: multiple source locations" if target.source_locations.many?

      dependency_source_location = target.source_locations.first

      dependency_is_declared_in_the_same_file =
        dependency_source_location.file_path == something.source_location.file_path

      return if dependency_is_declared_in_the_same_file

      application.symbols.register_type_inference_dependency(
        dependency_source_location.file_path,
        something.identifier
      )
    end

    def solve_namespace_reference(application:, something:)
      has_namespace_reference_clue =
        something.clues.one? && something.clues.first.is_a?(Clue::NamespaceReference)

      return unless has_namespace_reference_clue

      namespace_reference = something.clues.first

      if namespace_reference.resolution_possibilities.root_scope?
        target_identifier = namespace_reference.name

        target = application.symbols.find(target_identifier)

        if target.present?
          RegisterTypeInferenceDependency.call(application:, something:, target:)

          something.conclusion = Conclusion.with_strong_confidence(target.identifier)

          return true
        end
      end

      namespace_reference.resolution_possibilities.each do |resolution_candidate|
        target_identifier = "::#{resolution_candidate}::#{namespace_reference.name}"

        target = application.symbols.find(target_identifier)

        if target.present?
          RegisterTypeInferenceDependency.call(application:, something:, target:)

          something.conclusion = Conclusion.with_strong_confidence(target.identifier)

          return true
        end
      end
    end
  end
end
