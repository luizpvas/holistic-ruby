# frozen_string_literal: true

module Holistic::Ruby::TypeInference::Clue
  ReferenceToSuperclass = ::Data.define(:subclass_scope) do
    def to_s
      nesting.to_s
    end
  end
end
