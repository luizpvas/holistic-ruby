# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Kind::Root
    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    def kind
      Kind::ROOT
    end

    def closest_namespace
      nil
    end

    def visible_to?(_other_scope)
      true
    end
  end
end

