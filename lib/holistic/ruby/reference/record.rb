# frozen_string_literal: true

module Holistic::Ruby::Reference
  Record = ::Struct.new(
    :scope,
    :clues,
    :location,
    :referenced_scope,
    :conclusion,
    keyword_init: true
  ) do
    def identifier = location.identifier
  end
end
