# frozen_string_literal: true

module Question::Ruby::Declaration
  class Record
    attr_reader :name, :kind, :namespace, :source_location

    def initialize(name:, kind:, namespace:, source_location:)
      @name = name
      @kind = kind
      @namespace = namespace # TODO: should the namespace have a list of declarations?
      @source_location = source_location
    end

    def identifier
      return namespace.fully_qualified_name + "::" + name if kind == :lambda

      raise "unknown kind: #{kind.inspect}"
    end

    def to_symbol
      ::Question::Ruby::Symbol::Record.new(
        identifier:,
        kind: :declaration,
        record: self,
        source_locations: [source_location],
        searchable?: true
      )
    end
  end
end
