# frozen_string_literal: true

module Holistic::Ruby::TypeInference
  class BagOfClues
    def initialize(clues = [])
      @clues = clues
    end

    def find(clue_class)
      @clues.find { _1.is_a?(clue_class) }
    end
  end
end
