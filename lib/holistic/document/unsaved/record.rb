# frozen_string_literal: true

module Holistic::Document
  class Unsaved::Record
    attr_reader :path, :content

    def initialize(path:, content:)
      @path = path
      @content = content
      @original_content = content.dup
    end

    def expand_code(cursor)
      line = 0
      column = 0

      @content.each_char.with_index do |char, index|
        if cursor.line == line && cursor.column == column + 1
          token_index = index

          while @content[token_index].match?(/[a-zA-Z0-9_\.:]/)
            token_index -= 1
          end

          return @content[token_index+1..index]
        end

        if char == LINE_BREAK
          line += 1
          column = 0
        else
          column += 1
        end
      end

      nil
    end

    def mark_as_saved!
      @original_content = @content.dup
    end

    def restore_original_content!
      @content = @original_content.dup
    end

    def has_unsaved_changes?
      @original_content != @content
    end

    LINE_BREAK = "\n"

    def apply_change(change)
      line = 0
      column = 0

      @content.each_char.with_index do |char, index|
        if change.insertion? && change.starts_on?(line, column)
          content.insert(index, change.text)

          return
        end

        if change.deletion? && change.starts_on?(line, column)
          content[index..index + change.range_length - 1] = ""

          return
        end

        if char == LINE_BREAK
          line += 1
          column = 0
        else
          column += 1
        end
      end
    end

    def to_file
      File::Record.new(path:, adapter: File::Adapter::Memory).tap do |file|
        file.write(content)
      end
    end
  end
end
