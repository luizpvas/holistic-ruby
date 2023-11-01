# frozen_string_literal: true

module Holistic::Document
  class Unsaved::Record
    attr_reader :path, :content

    def initialize(path:, content:)
      @path = path
      @content = content
      @original_content = content.dup
    end

    LINE_BREAK = "\n"

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

    def push_changes(changes)
      changes.each do |change|
        scanner = Scanner.new(@content)

        start_index = scanner.find_index(change.start_line, change.start_column)
        end_index = scanner.find_index(change.end_line, change.end_column)

        @content[start_index...end_index] = change.text
      end
    end
  end
end
