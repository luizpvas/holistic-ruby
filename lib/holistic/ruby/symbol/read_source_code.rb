# frozen_string_literal: true

module Holistic::Ruby::Symbol
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
      location =
        find_symbol_location(application:, symbol_identifier:) || build_empty_location_for_file(application:, file_path:)

      Result.new(
        file: application.files.find(location.file_path),
        symbols: application.symbols.list_symbols_in_file(location.file_path),
        start_line: location.start_line,
        start_column: location.start_column,
        end_line: location.end_line,
        end_column: location.end_column
      )
    end

    private

    def find_symbol_location(application:, symbol_identifier:)
      return if symbol_identifier.nil?

      symbol = application.symbols.find(symbol_identifier)

      raise ::ArgumentError, "symbol not found" if symbol.nil?
      raise ::NotImplementedError if symbol.locations.size != 1

      symbol.locations.first
    end

    def build_empty_location_for_file(application:, file_path:)
      file = application.files.find(file_path)

      ::Holistic::Document::Location.beginning_of_file(file.path)
    end
  end
end
