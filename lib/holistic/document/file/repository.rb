# frozen_string_literal: true

module ::Holistic::Document::File
  class Repository
    attr_reader :database

    def initialize(database:)
      @database = database
    end

    # rename to `find_file`
    def find(file_path)
      @database.find(file_path)
    end

    concerning :TestHelpers do
      def build_fake_location(file_path)
        file = Register.call(database:, file_path:)

        ::Holistic::Document::Location.new(file, 0, 0, 0, 0)
      end
    end
  end
end
