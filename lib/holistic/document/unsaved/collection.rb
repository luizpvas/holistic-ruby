# frozen_string_literal: true

module Holistic::Document::Unsaved
  class Collection
    def initialize
      @items = {}
    end

    def add(path:, content:)
      @items[path] = Record.new(content)
    end

    def delete(path)
      @items.delete(path)
    end

    def find(path)
      @items[path]
    end
  end
end
