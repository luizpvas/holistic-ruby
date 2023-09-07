# frozen_string_literal: true

module Holistic::Ruby::TypeInference
  class ProcessingQueue
    def initialize
      @high_priority_queue = ::Queue.new
      @queue = ::Queue.new
    end

    def push(item)
      @queue.push(item)
    end

    def push_with_high_priority(item)
      @high_priority_queue.push(item)
    end

    def empty?
      @high_priority_queue.empty? && @queue.empty?
    end

    def pop
      return @high_priority_queue.pop if @high_priority_queue.size > 0

      @queue.pop
    end
  end
end
