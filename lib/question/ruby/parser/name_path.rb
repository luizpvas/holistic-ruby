# frozen_string_literal: true

module Question::Ruby::Parser
  class NamePath
    attr_reader :value

    def initialize(value = [])
      @value = value
    end

    def to_s
      @value.join("::")
    end

    delegate :each, to: :value
    delegate :<<,   to: :value
  end
end
