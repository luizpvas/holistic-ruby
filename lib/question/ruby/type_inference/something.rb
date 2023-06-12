# frozen_string_literal: true

module Question::Ruby::TypeInference
  Something = ::Struct.new(
    :clues,
    :conclusion,
    :source_location,
    keyword_init: true
  ) do
    def identifier = source_location.identifier

    # TODO: is this right?
    def to_symbol
      ::Question::Ruby::Symbol::Record.new(
        identifier:,
        kind: :type_inference,
        record: self,
        source_locations: [source_location]
      )
    end

    # We don't have to do anything because there are no references to this instance other than
    # the symbols collection.
    def delete(_file_path)
      nil
    end
  end
end
