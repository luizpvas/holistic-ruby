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
  
      # TODO: use more meaningful name to describe `resolves at root scope`?
      if namespace_reference.resolution_possibilities.empty? 
        target_identifier = namespace_reference.name

        if application.symbol_index.find(target_identifier).present?
          # at this point we could update the target's `who knows about me?` index

          something.conclusion = Conclusion.with_strong_confidence(target_identifier)

          return true
        end
      end

      namespace_reference.resolution_possibilities.each do |resolution_candidate|
        target_identifier = "::#{resolution_candidate}::#{namespace_reference.name}"

        if application.symbol_index.find(target_identifier).present?
          # at this point we could update the target's `who knows about me?` index

          something.conclusion = Conclusion.with_strong_confidence(target_identifier)

          return true
        end
      end
    end
  end
end
