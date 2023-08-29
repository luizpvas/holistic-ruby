# frozen_string_literal: true

module Holistic::Ruby::Reference
  class Record < ::Holistic::Database::Node
    def identifier = attr(:identifier)
    def clues      = attr(:clues)
    def location   = attr(:location)

    def referenced_scope = has_one(:referenced_scope)
  end
end
