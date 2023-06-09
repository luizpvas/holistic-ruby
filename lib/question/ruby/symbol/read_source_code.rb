# frozen_string_literal: true

module Question::Ruby::Symbol
  module ReadSourceCode
    extend self

    Result = ::Struct.new(
      :file,
      :start_line,
      :start_column,
      :end_line,
      :end_column,
      keyword_init: true
    )

    def self.call(application:, symbol_identifier:)
      symbol = application.symbol_index.find(symbol_identifier)

      raise ::ArgumentError, "symbol not found" if symbol.nil?
      raise ::NotImplementedError if symbol.source_locations.size != 1

      source_location = symbol.source_locations.first

      Result.new(
        # TODO: could be fake? and it should work
        file: ::Question::SourceCode::File::Disk.new(path: source_location.file_path),
        start_line: source_location.start_line,
        start_column: source_location.start_column,
        end_line: source_location.end_line,
        end_column: source_location.end_column
      )
    end
  end
end
