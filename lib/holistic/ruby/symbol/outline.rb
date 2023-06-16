# frozen_string_literal: true

module Holistic::Ruby::Symbol
  module Outline
    extend self

    Result = ::Struct.new(
      :declarations,
      :dependencies,
      :dependants,
      keyword_init: true
    )

    def call(symbol:)
      raise ::ArgumentError, "#{symbol.inspect} must be a Symbol" unless symbol.is_a?(Record)

      Result.new(
        declarations: [],
        dependencies: [],
        dependants: []
      )
    end
  end
end
