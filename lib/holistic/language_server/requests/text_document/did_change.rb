# frozen_string_literal: true

require "ostruct"

module Holistic::LanguageServer
  module Requests::TextDocument::DidChange
    extend self

    BuildChange = ->(language_server_change) do
      ::Holistic::Document::Unsaved::Change.new(
        range_length: language_server_change["rangeLength"],
        text: language_server_change["text"],
        start_line: language_server_change.dig("range", "start", "line"),
        start_column: language_server_change.dig("range", "start", "character"),
        end_line: language_server_change.dig("range", "end", "line"),
        end_column: language_server_change.dig("range", "end", "character")
      )
    end

    def call(request)
      file_path = request.param("textDocument", "uri").gsub("file://", "")

      unsaved_document = request.application.unsaved_documents.find(file_path)

      request.param("contentChanges").map(&BuildChange).each do |change|
        unsaved_document.apply_change(change)
      end

      request.respond_with(nil)
    end
  end
end
