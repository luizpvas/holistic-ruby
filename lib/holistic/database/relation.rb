# frozen_string_literal: true

module Holistic::Database
  class Relation < ::Set
    def initialize(node:, name:, inverse_of:)
      @node = node
      @name = name
      @inverse_of = inverse_of

      super()
    end

    def add!(related_node)
      @node.connections[@name].add(related_node)
      related_node.connections[@inverse_of].add(@node)
    end

    def delete!(related_node)
      @node.connections[@name].delete(related_node)
      related_node.connections[@inverse_of].delete(@node)
    end
  end
end
