# frozen_string_literal: true

module Holistic::Ruby::Symbol
  Record = ::Struct.new(
    :identifier,
    :kind,
    :record,
    :source_locations,
    :searchable?,
    keyword_init: true
  ) do
    def to_search_document
      return unless searchable?

      ::Holistic::FuzzySearch::Document.new(
        identifier:,
        text: identifier,
        record: self
      )
    end

    def namespace
      record.namespace
    end

    def delete(file_path)
      record.delete(file_path)
    end
  end
end
