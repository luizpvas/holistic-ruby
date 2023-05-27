# frozen_string_literal: true

module Question::Ruby::Symbol
  module ReadSourceCode
    extend self

    Result = ::Struct.new(
      :code,
      :file_path,
      :line_number,
      :column_number
    )

    def self.call(application:, symbol_uuid:)
      symbol_document = application.symbol_index.find(symbol_uuid)
    end
  end
end
