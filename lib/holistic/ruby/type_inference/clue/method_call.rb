# frozen_string_literal: true

module Holistic::Ruby::TypeInference::Clue
  # TODO: Rename to ReferenceToMethod
  MethodCall = ::Data.define(
    :expression,
    :method_name,
    :resolution_possibilities
  ) do
    def to_s
      expression.to_s
    end
  end
end
