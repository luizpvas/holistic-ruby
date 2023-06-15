# frozen_string_literal: true

module Question::File
  class Collection
    def initialize(application:)
      @application = application
      @parsed_files = {}
    end

    def register_parsed_file(file)
      @parsed_files[file.path] = file
    end

    def find(path)
      # TODO: make sure path is inside application's root directory. Throw an error if not.
      @parsed_files[path] || Disk.new(path:)
    end
  end
end
