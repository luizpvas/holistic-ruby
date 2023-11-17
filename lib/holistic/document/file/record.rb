# frozen_string_literal: true

module Holistic::Document::File
  class Record < ::Holistic::Database::Node
    def path = attr(:path)

    def defines_scopes     = has_many(:defines_scopes)
    def defines_references = has_many(:defines_references)

    def external?
      path == External::FILE_PATH
    end
  end
end
