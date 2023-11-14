# frozen_string_literal: true

module Holistic::Ruby::Reference
  class TypeInference::Queue
    def initialize
      @high_priority    = ::Queue.new
      @default_priority = ::Queue.new
    end

    def push(reference)
      queue =
        if reference.resolve_type_inference_with_high_priority?
          @high_priority
        else
          @default_priority
        end

      queue.push(reference)
    end

    def empty?
      @high_priority.empty? && @default_priority.empty?
    end

    def pop
      return @high_priority.pop if @high_priority.size > 0

      @default_priority.pop
    end
  end
end
