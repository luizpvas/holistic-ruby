# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Kind::Class
    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    def surrounding_class
      @scope
    end
  end
end

