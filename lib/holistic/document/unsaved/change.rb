# frozen_string_literal: true

module Holistic::Document::Unsaved
  Change = ::Data.define(
    :range_length,
    :text,
    :start_line,
    :start_column,
    :end_line,
    :end_column
  ) do
    def insertion?
      text.size.positive? && start_line == end_line && start_column == end_column
    end

    def deletion?
      text.empty? && (start_line != end_line || start_column != end_column)
    end
  end
end
