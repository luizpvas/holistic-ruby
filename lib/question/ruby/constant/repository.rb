# frozen_string_literal: true

require "active_support/core_ext/module/delegation"

module Question::Ruby::Constant
  class Repository
    attr_reader :references

    def initialize
      @references = References.new
    end
  end
end
