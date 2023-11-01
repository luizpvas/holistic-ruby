# frozen_string_literal: true

module Holistic::LanguageServer
  module Requests::TextDocument::DidChange
    extend self

    BuildDocumentChange = ->(params) do
      ::Holistic::Document::Unsaved::Change.new(
        range_length: params.dig("rangeLength"),
        text: params.dig("text"),
        start_line: params.dig("range", "start", "line"),
        start_column: params.dig("range", "start", "character"),
        end_line: params.dig("range", "end", "line"),
        end_column: params.dig("range", "end", "character")
      )
    end

    def call(request)
      file_path = Format::FileUri.extract_path(request.param("textDocument", "uri"))

      unsaved_document = request.application.unsaved_documents.find(file_path)

      changes = request.param("contentChanges").map(&BuildDocumentChange)

      unsaved_document.push_changes(changes)

      request.respond_with(nil)
    end
  end
end
