# frozen_string_literal: true

module Holistic::Ruby::Symbol
  ToDocument = ->(symbol) do
    ::Holistic::FuzzySearch::Document.new(
      identifier: symbol.identifier,
      text: symbol.identifier,
      record: symbol
    )
  end
end