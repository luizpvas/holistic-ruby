# frozen_string_literal: true

module Holistic::Ruby::Reference
  module Register
    extend self

    def call(repository:, scope:, clues:, location:)
      conclusion = ::Holistic::Ruby::TypeInference::Conclusion.pending

      reference = ::Holistic::Ruby::TypeInference::Reference.new(scope:, clues:, location:, conclusion:)

      repository.register_reference(reference)
    end
  end
end
