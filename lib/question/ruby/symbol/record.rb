# frozen_string_literal: true

module Question::Ruby::Symbol
  Record = ::Struct.new(:identifier, :kind, :record, :source_locations, keyword_init: true) do
    def destroy = record.destroy
  end
end
