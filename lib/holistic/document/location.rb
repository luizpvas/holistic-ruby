# frozen_string_literal: true

module Holistic::Document
  Location = ::Data.define(
    :file,
    :start_line,
    :start_column,
    :end_line,
    :end_column
  ) do
    def self.beginning_of_file(file_path)
      new(File.new(path: file_path), 0, 0, 0, 0)
    end

    def identifier
      "#{file.path}[#{start_line},#{start_column},#{end_line},#{end_column}]"
    end

    def contains?(cursor)
      same_file = cursor.file_path == file.path
      contains_line = cursor.line >= start_line && cursor.line <= end_line
      
      contains_column =
        if start_line == end_line
          cursor.column > start_column && cursor.column <= end_column
        elsif start_line == cursor.line
          cursor.column > start_column
        elsif end_line == cursor.line
          cursor.column <= end_column
        else
          true
        end

      same_file && contains_line && contains_column
    end
  end
end
