# frozen_string_literal: true

module Holistic::Ruby::TypeInference::Clue
  ReferenceToSuperclass = ::Data.define(:subclass_scope) do
    def to_s
      "superclass of #{subclass_scope.fully_qualified_name}"
    end
  end
end
