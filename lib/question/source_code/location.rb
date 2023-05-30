# frozen_string_literal: true

module Question::SourceCode
  Location = ::Struct.new(
    :file_path,
    :start_line,
    :end_line,
    keyword_init: true
  )
end