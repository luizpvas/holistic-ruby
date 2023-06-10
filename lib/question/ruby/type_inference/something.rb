# frozen_string_literal: true

module Question::Ruby::TypeInference
  Something = ::Struct.new(
    :clues,
    :conclusion,
    :source_location,
    keyword_init: true
  ) do
    # TODO: is this right?
    def to_symbol
      ::Question::Ruby::Symbol::Record.new(
        identifier: source_location.identifier, # TODO
        kind: :type_inference,
        record: self,
        source_locations: [source_location]
      )
    end
  end
end
