# frozen_string_literal: true

class Holistic::Database::Relation < ::Set
  def initialize(node:, name:, inverse_of:)
    @node = node
    @name = name
    @inverse_of = inverse_of

    super()
  end

  def add!(related_node)
    @node.relations[@name].add(related_node)
    related_node.relations[@inverse_of].add(@node)
  end

  def delete!(related_node)
    @node.relations[@name].delete(related_node)
    related_node.relations[@inverse_of].delete(@node)
  end
end
