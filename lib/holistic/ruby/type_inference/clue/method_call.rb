# frozen_string_literal: true

module Holistic::Ruby::TypeInference::Clue
  # TODO: Rename to ReferenceToMethod
  MethodCall = ::Data.define(
    :expression,
    :method_name,
    :resolution_possibilities
  ) do
    def to_s
      return method_name if expression.nil?

      "#{expression}.#{method_name}"
    end
  end
end
