# frozen_string_literal: true

module Holistic::Document
  Cursor = ::Data.define(
    :file_path,
    :line,
    :column
  )
end
