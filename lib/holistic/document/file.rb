# frozen_string_literal: true

module Holistic::Document
  class File
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

    class Fake
      attr_reader :path

      def initialize(path:, content:)
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
end
