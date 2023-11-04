# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Kind::Root
    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    def surrounding_class
      nil
    end
  end
end

