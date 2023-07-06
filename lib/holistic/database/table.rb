# frozen_string_literal: true

class Holistic::Database::Table
  RecordNotUniqueError = ::Class.new(::StandardError)

  PRIMARY_ATTRIBUTE = :identifier

  attr_reader :primary_index, :secondary_indices

  def initialize(indices: [])
    @primary_index = ::Hash.new

    @secondary_indices = indices.map do |attribute_name|
      [attribute_name, ::Hash.new { |hash, key| hash[key] = ::Set.new }]
    end.to_h
  end

  def insert(record)
    primary_key = record.fetch(PRIMARY_ATTRIBUTE)

    if primary_index.key?(primary_key)
      raise RecordNotUniqueError, "record already inserted: #{record.inspect}"
    end

    primary_index[primary_key] = record

    secondary_indices.each do |attribute_name, secondary_index|
      Array(record[attribute_name]).each do |value|
        secondary_index[value].add(primary_key)
      end
    end
  end

  def find(identifier)
    primary_index[identifier]
  end

  def filter(name, value)
    return [] unless secondary_indices[name].key?(value)

    secondary_indices.dig(name, value).to_a.map { find(_1) }
  end

  def update(record)
    primary_key = record.fetch(PRIMARY_ATTRIBUTE)

    delete(primary_key)

    insert(record)
  end

  def delete(primary_key)
    record = find(primary_key)

    return if record.nil?

    primary_index.delete(primary_key)

    secondary_indices.each do |attribute_name, index_data|
      Array(record[attribute_name]).each do |value|
        index_data[value].delete(primary_key)
        index_data.delete(value) if index_data[value].empty?
      end
    end

    record
  end

  concerning :TestHelpers do
    def all
      primary_index.values
    end

    def size
      primary_index.size
    end
  end
end
