# frozen_string_literal: true

module Question::FuzzySearch
  Document = ::Struct.new(:text, :record, keyword_init: true)
end
