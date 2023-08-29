
# frozen_string_literal: true

module Holistic::Database
  class Table
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

    def store(id, attributes)
      if @records.key?(id)
        return @records[id]&.tap do |node|
          node.attributes = attributes
        end
      end

      @records[id] =
        case attributes
        in ::Hash then Node.new(id, attributes)
        in Node   then attributes
        end
    end

    def connect(source:, target:, name:, inverse_of:)
      connection = @connections[name]

      raise ::ArgumentError if connection.nil? || connection[:inverse_of] != inverse_of

      source.connections[name].add(target)
      target.connections[inverse_of].add(source)
    end

    def disconnect(source:, target:, name:, inverse_of:)
      connection = @connections[name]

      raise ::ArgumentError if connection.nil? || connection[:inverse_of] != inverse_of

      source.connections[name].delete(target)
      target.connections[inverse_of].delete(source)
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
end
