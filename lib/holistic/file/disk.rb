# frozen_string_literal: true

module Holistic::File
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
