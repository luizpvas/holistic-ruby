# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Kind::InstanceMethod
    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    def kind
      Kind::INSTANCE_METHOD
    end

    def surrounding_class
      @scope.lexical_parent
    end

    def visible_to?(other_scope)
      other_scope.instance_method?
    end
  end
end

