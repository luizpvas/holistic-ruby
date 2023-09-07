# frozen_string_literal: true

module Holistic::Ruby::Reference
  class Record < ::Holistic::Database::Node
    def identifier = attr(:identifier)
    def clues      = attr(:clues)
    def location   = attr(:location)

    def referenced_scope = has_one(:referenced_scope)
    def located_in_scope = has_one(:located_in_scope)

    def find_clue(clue_kind)
      clues.find { |clue| clue.is_a?(clue_kind) }
    end

    def has_clue?(clue_kind)
      find_clue(clue_kind).present?
    end
  end
end
