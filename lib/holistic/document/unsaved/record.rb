# frozen_string_literal: true

module Holistic::Document::Unsaved
  class Record
    attr_reader :content

    def initialize(content)
      @content = content
    end

    LINE_BREAK = "\n"

    def apply_change(change)
      line = 0
      column = 0

      @content.each_char.with_index do |char, index|
        if change.insertion?
          if change.start_line == line && change.start_column == column
            content.insert(index, change.text)

            return
          end
        end

        if change.deletion?
          if change.start_line == line && change.start_column == column
            content[index..index + change.range_length - 1] = ""

            return
          end
        end

        if char == LINE_BREAK
          line += 1
          column = 0
        else
          column += 1
        end
      end
    end
  end
end
