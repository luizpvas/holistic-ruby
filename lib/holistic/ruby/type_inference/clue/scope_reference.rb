# frozen_string_literal: true

module Holistic::Ruby::TypeInference::Clue
  # TODO: rename to ReferenceToScope
  ScopeReference = ::Struct.new(
    :expression,
    :resolution_possibilities,
    keyword_init: true
  ) do
    def to_s
      expression.to_s
    end
  end
end
