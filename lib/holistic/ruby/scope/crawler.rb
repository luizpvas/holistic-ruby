# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Crawler
    def initialize(application:, scope:)
      @application = application
      @scope = scope
    end

    def visible_scopes
      ancestors.flat_map { [_1] + _1.lexical_children }.filter do |scope|
        scope.visible_to?(@scope)
      end
    end

    Ancestors = ->(scope) do
      scope.ancestors.flat_map do |ancestor|
        [ancestor] + Ancestors[ancestor]
      end
    end

    def ancestors
      target_class = @scope.surrounding_class

      [target_class] + Ancestors[target_class]
    end
  end
end
