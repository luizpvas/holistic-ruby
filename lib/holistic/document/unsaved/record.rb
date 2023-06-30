# frozen_string_literal: true

module Holistic::Document::Unsaved
  class Record
    attr_reader :content

    def initialize(content)
      @content = content
    end
  end
end
