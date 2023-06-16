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

    MagneticBackwardPass = ->(query, document, matched_indices) do
      index = query.length - 1

      while index > 0
        document_index = matched_indices[index]
        previous_document_index = matched_indices[index - 1]

        if document_index == previous_document_index + 1
          index -= 1 and next
        end

        previous_query_character = query[index - 1]
        previous_document_character = document.text[document_index - 1]

        # TODO: remove the need to `downcase` by doing it once.
        if previous_query_character.downcase == previous_document_character.downcase
          matched_indices[index - 1] = document_index - 1
        end

        index -= 1
      end

      matched_indices
    end

    IsSeparator = ->(character) { character == ":" || character == "#" }
    IsUpperCase = ->(character) { character.present? && character.match?(/[A-Z]/) }
    IsLowerCase = ->(character) { character.present? && character.match?(/[a-z]/) }

    CalculateScore = ->(document, matched_indices) do
      unmatched_characters = document.text.length - matched_indices.length

      # Score starts at -1 point per unmatched letter to penalize longer documents
      score = unmatched_characters * -1

      matched_indices.each_with_index do |document_index, loop_index|
        # Consecutive match bonus: +5 points
        if matched_indices[loop_index + 1] == document_index + 1
          score += 5
        end

        # Separator bonus: +10 points
        if document_index.zero? || IsSeparator[document.text[document_index - 1]]
          score += 10
        end

        # CamelCase bonus: +10 points
        if IsUpperCase[document.text[document_index]] && IsLowerCase[document.text[document_index + 1]]
          score += 10
        end
      end

      score
    end

    MatchesQuery = ->(query, document) do
      query_index     = 0
      document_index  = 0
      matched_indices = []

      while query_index < query.length && document_index < document.text.length
        if query[query_index].downcase == document.text[document_index].downcase
          query_index += 1
          matched_indices << document_index
        end

        document_index += 1
      end

      if query_index == query.length
        matched_indices = MagneticBackwardPass[query, document, matched_indices]

        score = CalculateScore[document, matched_indices]

        Match.new(
          document:,
          highlighted_text: Highlight::Apply[document.text, matched_indices],
          score:
        )
      end
    end

    Result = ::Struct.new(
      :elapsed_time_in_seconds,
      :matches,
      keyword_init: true
    )

    def call(query:, documents:)
      starting_time = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)

      matches = documents.filter_map(&MatchesQuery.curry[query]).sort_by(&:score).reverse

      ending_time = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)

      Result.new(
        elapsed_time_in_seconds: ending_time - starting_time,
        matches:
      )
    end
  end
end