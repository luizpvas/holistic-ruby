# frozen_string_literal: true

module Holistic::Ruby::TypeInference::Resolver::ClassMethod
  extend self

  def resolve(application:, scope:, method_name:)
    method_fully_qualified_name = "#{scope.fully_qualified_name}.#{method_name}"

    application.scopes.find(method_fully_qualified_name)
  end
end
