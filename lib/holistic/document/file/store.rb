# frozen_string_literal: true

module Holistic::Document::File
  module Store
    extend self

    def call(database:, file_path:)
      record = Record.new(file_path, { path: file_path })

      database.store(file_path, record)
    end
  end
end
