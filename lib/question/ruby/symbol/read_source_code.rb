# frozen_string_literal: true

module Question::Ruby::Symbol
  # TODO: Move out of `Symbol` namespace
  module ReadSourceCode
    extend self

    Result = ::Struct.new(
      :file,
      :symbols,
      :start_line,
      :start_column,
      :end_line,
      :end_column,
      keyword_init: true
    )

    # TODO: the current implementation is a little weird. we instantiate a source location for `file_path`
    # and then find the file again.
    def self.call(application:, symbol_identifier: nil, file_path: nil)
      source_location =
        find_symbol_source_location(application:, symbol_identifier:) || find_file_source_location(application:, file_path:)

      Result.new(
        file: application.files.find(source_location.file_path),
        symbols: application.symbols.list_symbols_in_file(source_location.file_path),
        start_line: source_location.start_line,
        start_column: source_location.start_column,
        end_line: source_location.end_line,
        end_column: source_location.end_column
      )
    end

    private

    def find_symbol_source_location(application:, symbol_identifier:)
      return if symbol_identifier.nil?

      symbol = application.symbols.find(symbol_identifier)

      raise ::ArgumentError, "symbol not found" if symbol.nil?
      raise ::NotImplementedError if symbol.source_locations.size != 1

      symbol.source_locations.first
    end

    def find_file_source_location(application:, file_path:)
      file = application.files.find(file_path)

      ::Question::SourceCode::Location.new(file_path: file.path)
    end
  end
end
