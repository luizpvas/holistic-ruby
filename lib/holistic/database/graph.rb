# frozen_string_literal: true

# nodes
# 
# files
# scopes
# references
#
# relations
#
# file -> defines many -> scopes (n-n)
# file -> defines many -> references (1-n)
# scope -> contains many -> scopes (1-n)
# scope -> defines many -> references (1-n)
# scope -> is referenced by many -> references (1-n)
#
# database = Graph.new
# file = database.store({ id: "/path/to/myfile.rb", last_modified_at: 1234 })
# node = database.store({ id: "::MyApp::Something", key: "value" })
#
# file_node = database.store("/path/to/myfile.rb", { last_modified_at: 1234 })
# database.relate(file_node, reference_node, :definition)
# 
class Holistic::Database::Graph
  class Node
    attr_accessor :id, :attributes, :connections

    def initialize(id:, attributes:)
      @id = id
      @attributes = attributes
      @connections = ::Hash.new { |hash, key| hash[key] = ::Set.new }
    end

    def [](key)
      attributes[key]
    end

    def connection(name)
      connections[name]
    end

    def belongs_to(name)
      connected_nodes = connections[name]

      raise ::ArgumentError if connected_nodes.size != 1

      connected_nodes.first
    end
  end

  def initialize
    @nodes = {}
    @indices = {}
    @connection_definitions = {}
  end

  def add_index(attribute_name)
    @indices[attribute_name] = ::Hash.new { |hash, attribute_value| hash[attribute_value] = ::Set.new }
  end

  def define_connection(name:, inverse_of:)
    raise ::ArgumentError if @connection_definitions.key?(name) || @connection_definitions.key?(inverse_of)

    @connection_definitions[name] = { inverse_of: }
    @connection_definitions[inverse_of] = { inverse_of: name }
  end

  def store(id, attributes)
    if @nodes.key?(id)
      node = @nodes[id]

      @indices.each do |attribute_name, index_data|
        Array(node[attribute_name]).each do |previous_value|
          index_data[previous_value].delete(node)
        end
      end

      node.attributes = attributes

      @indices.each do |attribute_name, index_data|
        Array(node[attribute_name]).each do |attribute_value|
          index_data[attribute_value].add(node)
        end
      end

      return node
    else
      node = Node.new(id:, attributes:)

      @indices.each do |attribute_name, index_data|
        Array(node[attribute_name]).each do |attribute_value|
          index_data[attribute_value].add(node)
        end
      end

      @nodes[id] = node

      return node
    end
  end

  def find(id)
    @nodes[id]
  end

  def filter(attribute_name, value)
    return [] unless @indices[attribute_name].key?(value)

    @indices[attribute_name][value].to_a
  end

  def connect(source:, target:, name:, inverse_of:)
    connection_definition = @connection_definitions[name]
    raise ::ArgumentError if connection_definition.nil? || connection_definition[:inverse_of] != inverse_of

    source.connections[name].add(target)
    target.connections[inverse_of].add(source)
  end

  def delete(id)
    deleted_node = @nodes[id]

    return if deleted_node.nil?

    deleted_node.connections.each do |connection_name, connected_nodes|
      connection_definition = @connection_definitions[connection_name]

      connected_nodes.each do |related_node|
        related_node.connection(connection_definition[:inverse_of]).delete(deleted_node)
      end
    end

    @nodes.delete(id)
  end
end
