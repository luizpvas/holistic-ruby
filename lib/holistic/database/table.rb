# frozen_string_literal: true

class Holistic::Database::Table
  RecordNotUniqueError = ::Class.new(::StandardError)

  attr_reader :indices

  def initialize(indices: [])
    @indices =
      indices.append(:identifier).map do |attribute_name|
        [attribute_name, ::Hash.new { |hash, key| hash[key] = ::Set.new }]
      end.to_h
  end

  def insert(data)
    primary_key = data.fetch(:identifier)

    if identifier_index.key?(primary_key)
      raise RecordNotUniqueError, "record already inserted: #{data.inspect}"
    end

    indices.each do |attribute_name, index_data|
      Array(data[attribute_name]).each do |value|
        index_data[value].add(data)
      end
    end
  end

  def find(identifier)
    return unless identifier_index.key?(identifier)

    identifier_index[identifier].first
  end

  def filter(attribute_name, value)
    return unless indices[attribute_name].key?(value)

    indices.dig(attribute_name, value).to_a
  end

  def update(record)
    primary_key = record.fetch(:identifier)

    delete(primary_key)

    insert(record)
  end

  def delete(identifier)
    return unless identifier_index.key?(identifier)

    record = identifier_index[identifier].first

    indices.each do |attribute_name, index_data|
      Array(record[attribute_name]).each do |value|
        index_data[value].delete(record)
        index_data.delete(value) if index_data[value].empty?
      end
    end

    record
  end

  def count
    identifier_index.size
  end

  private

  def identifier_index
    indices[:identifier]
  end
end
