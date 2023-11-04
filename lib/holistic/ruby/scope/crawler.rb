# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Crawler
    def initialize(application:, scope:)
      @application = application
      @scope = scope
    end

    def sibling_methods
      if @scope.instance_method?
      elsif @scope.class_method?
      else
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
