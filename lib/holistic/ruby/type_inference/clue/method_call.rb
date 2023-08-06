# frozen_string_literal: true

module Holistic::Ruby::TypeInference::Clue
  MethodCall = ::Data.define(
    :nesting,
    :method_name,
    :resolution_possibilities
  ) do
    def to_s
      return method_name if nesting.nil?

      "#{nesting}.#{method_name}"
    end
  end
end
