# frozen_string_literal: true

module Holistic::Ruby::Parser
  class NestingSyntax
    attr_reader :value, :is_root_scope

    def initialize(value = [])
      @value = Array(value)
      @is_root_scope = false
    end

    def mark_as_root_scope!
      @is_root_scope = true
    end

    def eql?(other)
      other.class == self.class && other.to_s == to_s
    end

    alias == eql?

    def to_s
      @value.join("::")
    end

    def root_scope_resolution? = is_root_scope

    delegate :each, to: :value
    delegate :<<,   to: :value
  end
end
