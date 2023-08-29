# frozen_string_literal: true

module Holistic::LanguageServer
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_references
  module Requests::TextDocument::FindReferences
    extend self

    def call(request)
      cursor = build_cursor_from_params(request)

      request.application.unsaved_documents.find(cursor.file_path)&.then do |unsaved_document|
        if unsaved_document.has_unsaved_changes?
          ::Holistic::Ruby::Parser::LiveEditing::ProcessFileChanged.call(
            application: request.application,
            file_path: unsaved_document.path,
            content: unsaved_document.content
          )
        end
      end

      case ::Holistic::Ruby::Scope::ListReferences.call(application: request.application, cursor:)
      in :not_found
        request.respond_with(nil)
      in [:references_listed, {references:}]
        respond_with_locations(request, references)
      end
    end

    private

    def build_cursor_from_params(request)
      file_path = Format::FileUri.extract_path(request.param("textDocument", "uri"))
      line = request.param("position", "line")
      column = request.param("position", "character")

      ::Holistic::Document::Cursor.new(file_path:, line:, column:)
    end

    def respond_with_locations(request, references)
      locations = references.map do |reference|
        location = reference.location

        {
          "uri" => Format::FileUri.from_path(location.file.attr(:path)),
          "range" => {
            "start" => { "line" => location.start_line, "character" => location.start_column },
            "end" => { "line" => location.end_line, "character" => location.end_column }
          }
        }
      end

      request.respond_with(locations)
    end
  end
end