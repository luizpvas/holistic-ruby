# frozen_string_literal: true

class Holistic::Database::Table
  attr_reader :records, :indices

  def initialize(indices: [])
    @records = ::Hash.new

    @indices = indices.map do |attribute_name|
      [attribute_name, ::Hash.new { |hash, key| hash[key] = ::Set.new }]
    end.to_h
  end

  def store(id, record)
    delete(id) if records.key?(id)

    @records[id] = record

    @indices.each do |attribute_name, index_data|
      Array(record[attribute_name]).each do |value|
        index_data[value].add(id)
      end
    end
  end

  def find(id)
    @records[id]
  end

  def filter(name, value)
    return [] unless indices[name].key?(value)

    indices.dig(name, value).to_a.map { find(_1) }
  end

  def delete(id)
    record = find(id)

    return if record.nil?

    records.delete(id)

    indices.each do |attribute_name, index_data|
      Array(record[attribute_name]).each do |value|
        index_data[value].delete(id)
        index_data.delete(value) if index_data[value].empty?
      end
    end

    record
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
