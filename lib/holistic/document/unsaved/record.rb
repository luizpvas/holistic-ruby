# frozen_string_literal: true

module Holistic::Document
  class Unsaved::Record
    attr_reader :path, :content

    def initialize(path:, content:)
      @path = path
      @content = content
      @original_content = content.dup
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

    def expand_code(cursor)
      scanner = Scanner.new(@content)
      index = scanner.find_index(cursor.line, cursor.column)
      token_index = index - 1

      while @content[token_index].match?(/[a-zA-Z0-9_\.:]/)
        token_index -= 1
      end

      @content[token_index+1...index]
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
