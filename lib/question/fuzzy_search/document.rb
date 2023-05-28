# frozen_string_literal: true

module Question::FuzzySearch
  # TODO: do we really need two attributes? Will identifier ever differ from text?
  Document = ::Struct.new(:identifier, :text, keyword_init: true)
end
