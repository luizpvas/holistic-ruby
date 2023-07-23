# frozen_string_literal: true

module Holistic::Ruby::TypeInference
  module SolvePendingReferences
    extend self

    def call(application:)
      application.references.list_references_pending_type_inference_conclusion.each do |reference|
        Solve.call(application:, reference:)
      end
    end
  end
end
