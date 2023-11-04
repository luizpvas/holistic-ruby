# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Kind::Class
    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    def kind
      Kind::CLASS
    end

    def surrounding_class
      @scope
    end

    def visible_to?(_other_scope)
      true
    end
  end
end

