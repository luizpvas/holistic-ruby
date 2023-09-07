# frozen_string_literal: true

module Holistic::Ruby::TypeInference::Resolver::InstanceMethod
  extend self

  def resolve(scope:, method_name:)
    ::Holistic::Ruby::Scope::ListInstanceMethods.call(scope:).find { _1.name == method_name }
  end
end
