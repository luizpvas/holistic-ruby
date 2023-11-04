# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Kind::InstanceMethod
    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    def surrounding_class
      @scope.lexical_parent
    end
  end
end

