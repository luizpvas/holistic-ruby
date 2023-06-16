# frozen_string_literal: true

module Holistic::Ruby::TypeInference::Clue
  NamespaceReference = ::Struct.new(
    :name,
    :resolution_possibilities,
    keyword_init: true
  )
end
