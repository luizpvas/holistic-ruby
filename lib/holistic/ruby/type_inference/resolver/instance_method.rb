# frozen_string_literal: true

module Holistic::Ruby::TypeInference::Resolver::InstanceMethod
  extend self

  def resolve(application:, scope:, method_name:)
    method_fully_qualified_name = "#{scope.fully_qualified_name}##{method_name}"

    method_scope = application.scopes.find(method_fully_qualified_name)

    return method_scope if method_scope.present?

    scope.ancestors.each do |ancestor|
      method_scope = resolve(application:, scope: ancestor, method_name:)

      return method_scope if method_scope.present?
    end

    nil
  end
end
