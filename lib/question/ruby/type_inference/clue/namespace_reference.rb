# frozen_string_literal: true

module Question::Ruby::TypeInference::Clue
  NamespaceReference = ::Struct.new(
    :name,
    :resolution_possibilities,
    keyword_init: true
  )
end
