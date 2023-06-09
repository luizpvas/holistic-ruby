# frozen_string_literal: true

module Question::Ruby::TypeInference::Clue
  NamespaceReference = ::Struct.new(
    :name,
    :resolution,
    keyword_init: true
  )
end
