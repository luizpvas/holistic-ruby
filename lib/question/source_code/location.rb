# frozen_string_literal: true

module Question::SourceCode
  Location = ::Struct.new(
    :file_path,
    :start_line,
    :start_column,
    :end_line,
    :end_column,
    keyword_init: true
  ) do
    def identifier = "#{file_path}[#{start_line},#{start_column},#{end_line},#{end_column}]"
  end
end