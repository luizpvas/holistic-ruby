# frozen_string_literal: true

class Holistic::Ruby::TypeInference::ProcessingQueue
  def initialize
    @queue = ::Queue.new
  end

  def push(reference)
    @queue.push(reference)
  end

  def pop
    @queue.pop(true)
  end

  def empty?
    @queue.empty?
  end
end
