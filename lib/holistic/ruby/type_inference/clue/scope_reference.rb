# frozen_string_literal: true

module Holistic::Ruby::TypeInference::Clue
  ScopeReference = ::Struct.new(
    :nesting,
    :resolution_possibilities,
    keyword_init: true
  ) do
    def to_s
      nesting.to_s
    end
  end
end
