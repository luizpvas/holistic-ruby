# frozen_string_literal: true

module Question::Ruby::TypeInference
  Something = ::Struct.new(
    :source_location,
    :clues,
    keyword_init: true
  )
end
