# frozen_string_literal: true

class Holistic::Document::File
  module Register
    extend self

    def call(repository:, file_path:)
      find_existing_file(repository:, file_path:) || store_new_file(repository:, file_path:)
    end

    private

    def find_existing_file(repository:, file_path:)
      repository.find(file_path)
    end

    def store_new_file(repository:, file_path:)
      ::Holistic::Document::File.new(path: file_path).tap do |file|
        repository.store(file)
      end
    end
  end
end
