# frozen_string_literal: true

module Holistic::Document
  Location = ::Data.define(
    :file_path,
    :start_line,
    :start_column,
    :end_line,
    :end_column
  ) do
    def self.beginning_of_file(file_path)
      new(file_path, 0, 0, 0, 0)
    end

    def identifier = "#{file_path}[#{start_line},#{start_column},#{end_line},#{end_column}]"

    def contains?(cursor)
      same_file = cursor.file_path == file_path
      contains_line = cursor.line >= start_line && cursor.line <= end_line
      contains_column = cursor.column > start_column && cursor.column <= end_column

      same_file && contains_line && contains_column
    end
  end
end
