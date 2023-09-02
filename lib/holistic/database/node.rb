# frozen_string_literal: true

class Holistic::Database::Node
  attr_accessor :attributes, :connections, :__database__

  def initialize(id, attributes)
    @id = id
    @attributes = attributes
    @connections = ::Hash.new(&method(:build_relation_hash))
  end

  def attr(attribute_name)
    @attributes[attribute_name]
  end

  def relation(relation_name)
    @connections[relation_name]
  end

  def has_many(connection_name)
    @connections[connection_name].to_a
  end

  def has_one(connection_name)
    @connections[connection_name].first
  end

  private

  def build_relation_hash(hash, name)
    inverse_of = __database__.connections.dig(name, :inverse_of)

    raise ::ArgumentError, "unknown relation: #{name}" if inverse_of.nil?

    hash[name] = ::Holistic::Database::Relation.new(node: self, name:, inverse_of:)
  end
end
