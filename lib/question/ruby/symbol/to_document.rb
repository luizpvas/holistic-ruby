# frozen_string_literal: true

module Question::Ruby::Symbol
  ToDocument = ->(symbol) do
    ::Question::FuzzySearch::Document.new(
      uuid: symbol.identifier,
      text: symbol.identifier,
      record: symbol
    )
  end
end