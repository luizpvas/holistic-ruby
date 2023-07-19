# frozen_string_literal: true

module Holistic::Ruby::TypeInference::Clue
  ScopeReference = ::Struct.new(
    :name,
    :resolution_possibilities,
    keyword_init: true
  ) do
    def to_s
      name
    end
  end
end
