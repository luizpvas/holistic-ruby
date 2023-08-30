# frozen_string_literal: true

module Holistic::Document::File
  class Record < ::Holistic::Database::Node
    def path = attr(:path)
  end
end
