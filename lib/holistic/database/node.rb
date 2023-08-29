# frozen_string_literal: true

module Holistic::Database
  class Node
    attr_accessor :attributes, :connections

    def initialize(id, attributes)
      @id = id
      @attributes = attributes
      @connections = ::Hash.new { |hash, key| hash[key] = ::Set.new }
    end

    def attr(attribute_name)
      @attributes[attribute_name]
    end

    def has_many(connection_name)
      @connections[connection_name].to_a
    end

    def has_one(connection_name)
      @connections[connection_name].first
    end
  end
end