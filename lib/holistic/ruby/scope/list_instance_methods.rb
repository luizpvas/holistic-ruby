# frozen_string_literal: true

module Holistic::Ruby::Scope::ListInstanceMethods
  extend self

  def call(scope:)
    instance_methods = scope.lexical_children.filter(&:instance_method?)
    instance_method_names = ::Set.new(instance_methods.map(&:name))

    ancestor_methods = scope.ancestors.flat_map do |ancestor|
      ancestor_methods = call(scope: ancestor)

      # reject parent methods that were overriden by the subclass
      ancestor_methods.reject { |method| instance_method_names.include?(method.name) }
    end

    instance_methods + ancestor_methods
  end
end