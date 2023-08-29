# frozen_string_literal: true

module Holistic::Ruby::Reference
  class Record < ::Holistic::Database::Node
    def identifier = attr(:identifier)
    def clues      = attr(:clues)
    def location   = attr(:location)
  end
end
