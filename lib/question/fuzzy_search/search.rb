# frozen_string_literal: true

module Question::FuzzySearch
  module Search
    extend self

    module Highlight
      OPEN_TAG = "<em>"
      CLOSE_TAG = "</em>"
      TAG_SHIFT = OPEN_TAG.length + CLOSE_TAG.length

      Apply = ->(word, indices) do
        indices_next_to_each_other = indices.chunk_while { |i, j| i + 1 == j }.to_a

        indices_next_to_each_other.each_with_index.reduce(word.dup) do |word, (indices, shift)|
          shift *= TAG_SHIFT
          open_index = indices.first + shift
          close_index = indices.last + 1 + shift + OPEN_TAG.length

          word.insert(open_index, OPEN_TAG)
          word.insert(close_index, CLOSE_TAG)
        end
      end
    end

    ContainsQueryCharactersInOrder = ->(query, word) do
      query_index = 0
      word_index = 0
      matched_indices = []

      while query_index < query.length && word_index < word.length
        if query[query_index].downcase == word[word_index].downcase
          query_index += 1
          matched_indices << word_index
        end

        word_index += 1
      end

      if query_index == query.length
        Match.new(
          word:,
          highlighted_word: Highlight::Apply[word, matched_indices],
          score: 0
        )
      end
    end

    def call(query:, words:)
      words.filter_map(&ContainsQueryCharactersInOrder.curry[query])
    end
  end
end