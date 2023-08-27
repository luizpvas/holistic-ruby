# frozen_string_literal: true

module Holistic::Ruby::TypeInference
  module SolvePendingReferences
    extend self

    def call(application:)
      until application.type_inference_processing_queue.empty?
        reference = application.type_inference_processing_queue.pop

        Solve.call(application:, reference:)
      end
    end
  end
end
