# frozen_string_literal: true

module Question::Ruby::Symbol
  module ReadSourceCode
    extend self

    Result = ::Struct.new(
      :source_code,
      :start_line,
      :end_line
    )

    def self.call(application:, symbol_identifier:)
      symbol = application.symbol_index.find(symbol_identifier)

      raise ::ArgumentError, "symbol not found" if symbol.nil?
      raise ::NotImplementedError if symbol.source_locations.size != 1

      source_location = symbol.source_locations.first

      Result.new(
        source_code: ::Question::SourceCode::FromFile.new(source_location.file_path),
        start_line: source_location.start_line,
        end_line: source_location.end_line
      )
    end
  end
end
