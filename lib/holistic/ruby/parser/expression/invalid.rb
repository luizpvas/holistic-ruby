# frozen_string_literal: true

module Holistic::Ruby::Parser::Expression
  class Invalid
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def valid? = false
  end
end
