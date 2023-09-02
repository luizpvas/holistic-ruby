# frozen_string_literal: true

class Holistic::Database
  attr_reader :records, :connections

  def initialize
    @records = ::Hash.new
    @connections = ::Hash.new
  end

  def define_connection(name:, inverse_of:)
    raise ::ArgumentError if @connections.key?(name) || @connections.key?(inverse_of)

    @connections[name] = { inverse_of: }
    @connections[inverse_of] = { inverse_of: name }
  end

  def store(id, node_or_attrs)
    if @records.key?(id)
      return @records[id]&.tap do |node|
        node.attributes =
          case node_or_attrs
          in ::Hash then node_or_attrs
          in Node   then node_or_attrs.attributes
          end
      end
    end

    node =
      case node_or_attrs
      in ::Hash then Node.new(id, node_or_attrs)
      in Node   then node_or_attrs
      end

    node.__database__ = self

    @records[id] = node
  end

  def find(id)
    @records[id]
  end

  def delete(id)
    records.delete(id)
  end

  concerning :TestHelpers do
    def all
      records.values
    end

    def size
      records.size
    end
  end
end
