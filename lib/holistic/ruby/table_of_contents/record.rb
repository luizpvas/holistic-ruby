# frozen_string_literal: true

module Holistic::Ruby::TableOfContents
  class Record < ::Holistic::Database::Node
    def scope_fully_qualified_name = attr(:scope_fully_qualified_name)
    def items = attr(:items)
  end
end
