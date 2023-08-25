# frozen_string_literal: true

module Holistic::Document
  class File
    attr_reader :path

    def initialize(path:, adapter: File::Disk)
      @path = path
      @adapter = adapter
    end

    def read
      @adapter.read(self)
    end

    def write(content)
      @adapter.write(self, content)
    end
  end
end
