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

    def supported?
      @value.any?
    end

    def unsupported?
      !supported?
    end

    def root_scope_resolution?
      is_root_scope
    end

    def constant?
      return false if unsupported?

      @value.last[0].then { _1 == _1.upcase }
    end

    def to_s
      @value.join("::")
    end

    def eql?(other)
      other.class == self.class && other.to_s == to_s
    end

    alias == eql?

    delegate :each, to: :value
    delegate :<<,   to: :value
  end
end
