# frozen_string_literal: true

module Holistic::Document::File
  module Register
    extend self

    def call(repository:, file_path:, adapter: Adapter::Disk)
      find_existing_file(repository:, file_path:) || store_new_file(repository:, file_path:, adapter:)
    end

    private

    def find_existing_file(repository:, file_path:)
      repository.find(file_path)
    end

    def store_new_file(repository:, file_path:, adapter:)
      Record.new(path: file_path, adapter:).tap do |file|
        repository.store(file)
      end
    end
  end
end
