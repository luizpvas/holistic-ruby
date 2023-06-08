# frozen_string_literal: true

module Question::SourceCode::File
  class Collection
    def initialize(application:)
      @application = application
      @parsed_files = {}
    end

    # TODO: is this only used in tests? Perhaps move to something that is test-specific?
    # ==================================================================================

    def register_parsed_file(file)
      @parsed_files[file.path] = file
    end

    def find(path)
      @parsed_files.fetch(path)
    end
  end
end
