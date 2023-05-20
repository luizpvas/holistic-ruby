# frozen_string_literal: true

module Question::Ruby::Parser
  class NamePath
    attr_reader :value, :is_top_const_ref

    def initialize(value = [])
      @value = value
      @is_top_const_ref = false
    end

    def mark_as_top_const_ref!
      @is_top_const_ref = true
    end

    def to_s
      @value.join("::")
    end

    delegate :each, to: :value
    delegate :<<,   to: :value
  end
end
