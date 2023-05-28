# frozen_string_literal: true

module Question::Ruby::Symbol
  Entity = ::Struct.new(
    :identifier,
    :kind,
    :record,
    :source_locations,
    keyword_init: true
  )
end
