# frozen_string_literal: true

module Holistic::Ruby::Scope::ListClassMethods
  extend self

  def call(scope:)
    class_methods = scope.lexical_children.filter(&:class_method?)
    class_method_names = ::Set.new(class_methods.map(&:name))

    ancestor_methods = scope.ancestors.flat_map do |ancestor|
      ancestor_methods = call(scope: ancestor)

      # reject parent methods that were overriden by the subclass
      ancestor_methods.reject { |method| class_method_names.include?(method.name) }
    end

    class_methods + ancestor_methods
  end
end
