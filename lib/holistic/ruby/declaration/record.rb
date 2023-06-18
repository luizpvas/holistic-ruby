# frozen_string_literal: true

module Holistic::Ruby::Declaration
  class Record
    attr_reader :identifier, :namespace, :source_location

    def initialize(identifier:, namespace:, source_location:)
      @identifier = identifier
      @namespace = namespace # TODO: should the namespace have a list of declarations?
      @source_location = source_location
    end

    def to_symbol
      ::Holistic::Ruby::Symbol::Record.new(
        identifier:,
        kind: :declaration,
        record: self,
        source_locations: [source_location],
        searchable?: true
      )
    end

    # We don't have to do anything because there are no references to this instance other than
    # the symbols collection.
    def delete(_file_path)
      nil
    end
  end
end
