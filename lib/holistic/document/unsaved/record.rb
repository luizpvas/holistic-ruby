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
      ::File.read(path).tap do |content_from_disk|
        @original_content = content_from_disk
        @content = content_from_disk
      end
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

      # first edition to the document is special because we can't iterate over the content to find the insert position.
      # there is nothing to iterate over.
      if @content.empty? && change.insertion?
        @content = change.text

        return
      end

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

      # off-by-one error to insert at the of the document
      if change.insertion? && change.starts_on?(line, column)
        content.insert(@content.length, change.text)
      end
    end
  end
end
