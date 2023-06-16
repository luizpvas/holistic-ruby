# frozen_string_literal: true

module Holistic::File
  class Fake
    attr_reader :path

    def initialize(path, content)
      @path = path
      @content = content
    end

    def read
      @content
    end

    def write(content)
      @content = content
    end
  end
end
