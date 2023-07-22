# frozen_string_literal: true

module Holistic::BackgroundProcess
  extend self

  def run(&block)
    ::Thread.new(&block).tap do |thread|
      thread.abort_on_exception = true
    end
  end
end
