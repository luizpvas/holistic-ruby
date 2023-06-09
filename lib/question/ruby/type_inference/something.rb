# frozen_string_literal: true

module Question::Ruby::TypeInference
  Something = ::Struct.new(
    :clues,
    :source_location,
    keyword_init: true
  )
end
