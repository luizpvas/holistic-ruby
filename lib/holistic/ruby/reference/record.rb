# frozen_string_literal: true

module Holistic::Ruby::Reference
  Record = ::Struct.new(
    :scope,
    :clues,
    :conclusion,
    :location,
    keyword_init: true
  ) do
    def identifier = location.identifier
  end
end