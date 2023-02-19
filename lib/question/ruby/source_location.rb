# frozen_string_literal: true

module Question::Ruby
  SourceLocation = ::Struct.new(
    :file_path,
    :start_line,
    :end_line,
    keyword_init: true
  )
end
