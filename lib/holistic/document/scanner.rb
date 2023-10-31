# frozen_string_literal: true

module Holistic::Document
  class Scanner
    attr_reader :source

    LINE_BREAK = "\n"

    def initialize(source)
      @source = source
    end

    def find_index(cursor)
      index = 0
      line = 0

      until line == cursor.line
        index += 1 until source[index] == LINE_BREAK
        index += 1
        line += 1
      end

      index + cursor.column
    end
  end
end
