# frozen_string_literal: true

module Holistic::Ruby::TypeInference
  module ResolvePendingReferences
    extend self

    def call(application:)
      until application.type_inference_processing_queue.empty?
        reference = application.type_inference_processing_queue.pop

        Resolve.call(application:, reference:)
      end
    end
  end
end
