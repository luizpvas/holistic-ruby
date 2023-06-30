# frozen_string_literal: true

module Holistic::Document
  class Unsaved::Collection
    def initialize
      @items = {}
    end

    def add(path:, content:)
      @items[path] = Unsaved::Record.new(path:, content:)
    end

    def delete(path)
      @items.delete(path)
    end

    def find(path)
      @items[path]
    end
  end
end
