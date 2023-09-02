# frozen_string_literal: true

class Holistic::Database
  attr_reader :records, :relations

  def initialize
    @records = ::Hash.new
    @relations = ::Hash.new
  end

  def define_relation(name:, inverse_of:)
    raise ::ArgumentError if @relations.key?(name) || @relations.key?(inverse_of)

    @relations[name] = { inverse_of: }
    @relations[inverse_of] = { inverse_of: name }
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
