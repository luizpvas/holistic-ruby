# frozen_string_literal: true

module Question::FuzzySearch
  Match = ::Struct.new(
    :word,
    :highlighted_word,
    :score,
    keyword_init: true
  )
end