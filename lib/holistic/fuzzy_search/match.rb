# frozen_string_literal: true

module Holistic::FuzzySearch
  Match = ::Struct.new(
    :document,
    :highlighted_text,
    :score,
    keyword_init: true
  )
end