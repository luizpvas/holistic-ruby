# frozen_string_literal: true

module Holistic::SourceCode
  # TODO: convert to Data

  Location = ::Struct.new(
    :file_path,
    :start_line,
    :start_column,
    :end_line,
    :end_column,
    keyword_init: true
  ) do
    def identifier = "#{file_path}[#{start_line},#{start_column},#{end_line},#{end_column}]"

    def contains?(cursor)
      same_file = cursor.file_path == file_path
      contains_line = cursor.line >= start_line && cursor.line <= end_line
      contains_column = cursor.column > start_column && cursor.column <= end_column

      same_file && contains_line && contains_column
    end
  end
end