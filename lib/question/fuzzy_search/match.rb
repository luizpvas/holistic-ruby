# frozen_string_literal: true

module Question::FuzzySearch
  Match = ::Struct.new(
    :document,
    :highlighted_text,
    :score,
    keyword_init: true
  )
end