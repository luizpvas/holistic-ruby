# frozen_string_literal: true

module Holistic::Document
  module File::External
    FILE_PATH = "<external-file>"

    def self.get(application:)
      return @location if @location

      file = File::Store.call(database: application.database, file_path: FILE_PATH)

      @location = Location.new(
        file:,
        start_line: 0,
        start_column: 0,
        end_line: 0,
        end_column: 0
      )
    end
  end
end
