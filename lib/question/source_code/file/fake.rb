# frozen_string_literal: true

module Question::SourceCode::File
  class Fake
    attr_reader :path

    def initialize(path, content)
      @path = path
      @content = content
    end

    def read
      @content
    end
  end
end
