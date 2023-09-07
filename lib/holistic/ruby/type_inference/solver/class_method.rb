# frozen_string_literal: true

module Holistic::Ruby::TypeInference::Solver::ClassMethod
  extend self

  def solve(application:, scope:, method_name:)
    method_fully_qualified_name = "#{scope.fully_qualified_name}.#{method_name}"

    application.scopes.find(method_fully_qualified_name)
  end
end
