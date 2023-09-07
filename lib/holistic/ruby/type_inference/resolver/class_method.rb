# frozen_string_literal: true

module Holistic::Ruby::TypeInference::Resolver::ClassMethod
  extend self

  def resolve(scope:, method_name:)
    ::Holistic::Ruby::Scope::ListClassMethods.call(scope:).find { _1.name == method_name }
  end
end
