# frozen_string_literal: true

module Question::SourceCode::File
  class Disk
    attr_reader :path

    def initialize(path:)
      @path = path
    end

    def read
      ::File.read(path)
    end

    def write(content)
      ::File.write(path, content)
    end
  end
end
