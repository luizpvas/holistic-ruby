# frozen_string_literal: true

module Question::Ruby::Source
  Location = ::Struct.new(
    :file_path,
    :start_line,
    :end_line,
    keyword_init: true
  )
end