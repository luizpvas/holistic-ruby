# frozen_string_literal: true

module Holistic::Document::File
  module Register
    extend self

    def call(database:, file_path:)
      database.store(file_path, { path: file_path })
    end
  end
end
