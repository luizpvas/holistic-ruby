# frozen_string_literal: true

module Holistic::Document
  class Buffer
    def initialize(path:, content:)
      @path = path
      @content = content
    end
  end
end
