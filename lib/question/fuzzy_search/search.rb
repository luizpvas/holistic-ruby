# frozen_string_literal: true

module Question::FuzzySearch
  module Search
    extend self

    module Highlight
      OPEN_TAG = "<em>"
      CLOSE_TAG = "</em>"
      TAG_SHIFT = OPEN_TAG.length + CLOSE_TAG.length

      Apply = ->(text, indices) do
        indices_next_to_each_other = indices.chunk_while { |i, j| i + 1 == j }.to_a

        indices_next_to_each_other.each_with_index.reduce(text.dup) do |text, (indices, shift)|
          shift *= TAG_SHIFT
          open_index = indices.first + shift
          close_index = indices.last + 1 + shift + OPEN_TAG.length

          text.insert(open_index, OPEN_TAG)
          text.insert(close_index, CLOSE_TAG)
        end
      end
    end

    MatchesQuery = ->(query, document) do
      query_index = 0
      document_index = 0
      matched_indices = []

      while query_index < query.length && document_index < document.text.length
        if query[query_index].downcase == document.text[document_index].downcase
          query_index += 1
          matched_indices << document_index
        end

        document_index += 1
      end

      if query_index == query.length
        Match.new(
          document:,
          highlighted_text: Highlight::Apply[document.text, matched_indices],
          score: 0
        )
      end
    end

    def call(query:, documents:)
      documents.filter_map(&MatchesQuery.curry[query])
    end
  end
end