# frozen_string_literal: true

module Holistic::Ruby::Symbol
  Record = ::Struct.new(
    :identifier,
    :kind,
    :record,
    :locations,
    keyword_init: true
  ) do
    def namespace
      record.namespace
    end

    def delete(file_path)
      record.delete(file_path)
    end
  end
end
