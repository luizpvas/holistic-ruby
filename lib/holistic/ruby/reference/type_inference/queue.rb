# frozen_string_literal: true

module Holistic::Ruby::Reference
  class TypeInference::Queue
    def initialize
      @high_priority    = ::Queue.new
      @default_priority = ::Queue.new
    end

    def push(item)
      @default_priority.push(item)
    end

    def push_with_high_priority(item)
      @high_priority.push(item)
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
