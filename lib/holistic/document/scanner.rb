# frozen_string_literal: true

module Holistic::Document
  class Scanner
    attr_reader :source

    LINE_BREAK = "\n"

    def initialize(source)
      @source = source
    end

    def find_index(line, column)
      current_index = 0
      current_line = 0

      until current_line == line
        current_index += 1 until source[current_index] == LINE_BREAK
        current_index += 1
        current_line += 1
      end

      current_index + column
    end
  end
end
