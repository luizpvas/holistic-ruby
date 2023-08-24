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
  Node = ::Struct.new(
    :attributes,
    :relations,
    keyword_init: true
  )

  def initialize
    @nodes = {}
    @indices = {}
  end

  def store(id, attributes)
    @nodes[id] = Node.new(attributes:, relations: {})
  end
end
