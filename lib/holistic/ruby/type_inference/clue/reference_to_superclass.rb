# frozen_string_literal: true

module Holistic::Ruby::TypeInference::Clue
  ReferenceToSuperclass = ::Struct.new(
    :subclass_scope,
    keyword_init: true
  ) do
    def to_s
      nesting.to_s
    end
  end
end
