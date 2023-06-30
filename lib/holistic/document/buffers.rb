# frozen_string_literal: true

module Holistic::Document
  class Buffers
    class Buffer
      attr_reader :content

      def initialize(content)
        @content = content
      end
    end

    def initialize
      @items = {}
    end

    def add(path:, content:)
      @items[path] = Buffer.new(content)
    end

    def delete(path)
      @items.delete(path)
    end

    def find(path)
      @items[path]
    end
  end
end
