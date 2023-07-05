# frozen_string_literal: true

class Holistic::Database::Table
  RecordNotUniqueError = ::Class.new(::StandardError)

  PRIMARY_KEY = :identifier

  attr_reader :indices

  def initialize(indices: [])
    @indices =
      indices.append(PRIMARY_KEY).map do |attribute_name|
        [attribute_name, ::Hash.new { |hash, key| hash[key] = ::Set.new }]
      end.to_h
  end

  def insert(data)
    primary_key = data.fetch(PRIMARY_KEY)

    if primary_key_index.key?(primary_key)
      raise RecordNotUniqueError, "record already inserted: #{data.inspect}"
    end

    indices.each do |attribute_name, index_data|
      Array(data[attribute_name]).each do |value|
        index_data[value].add(data)
      end
    end
  end

  def find(identifier)
    return unless primary_key_index.key?(identifier)

    primary_key_index[identifier].first
  end

  def filter(attribute_name, value)
    return unless indices[attribute_name].key?(value)

    indices.dig(attribute_name, value).to_a
  end

  def update(record)
    primary_key = record.fetch(PRIMARY_KEY)

    delete(primary_key)

    insert(record)
  end

  def delete(identifier)
    return unless primary_key_index.key?(identifier)

    record = primary_key_index[identifier].first

    indices.each do |attribute_name, index_data|
      Array(record[attribute_name]).each do |value|
        index_data[value].delete(record)
        index_data.delete(value) if index_data[value].empty?
      end
    end

    record
  end

  def count
    primary_key_index.size
  end

  private

  def primary_key_index
    @indices[PRIMARY_KEY]
  end
end
