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
      class_or_module = @scope.closest_namespace

      [class_or_module] + Ancestors[class_or_module]
    end

    def lexical_parents
      lexical_parents = [@scope.closest_namespace]

      while (parent = lexical_parents.last.lexical_parent)
        lexical_parents << parent
      end

      lexical_parents
    end
  end
end
