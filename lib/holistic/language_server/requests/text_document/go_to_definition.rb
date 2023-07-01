# frozen_string_literal: true

module Holistic::LanguageServer
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_definition
  module Requests::TextDocument::GoToDefinition
    extend self

    def call(request)
      cursor = build_cursor_from_params(request)

      request.application.unsaved_documents.find(cursor.file_path)&.then do |unsaved_document|
        if unsaved_document.has_unsaved_changes?
          ::Holistic::Ruby::Parser::LiveEditing::ProcessFileChanged.call(
            application: request.application,
            file: unsaved_document.to_file
          )
        end
      end

      case ::Holistic::Ruby::Symbol::FindDefinition.call(application: request.application, cursor:)
      in :not_found                              then request.respond_with(nil)
      in [:origin_is_not_a_reference, {origin:}] then request.respond_with(nil)
      in [:could_not_find_definition, {origin:}] then request.respond_with(nil)
      in [:definition_found, {origin:, target:}] then respond_with_location_link(request, origin, target)
      end
    end

    private

    def build_cursor_from_params(request)
      file_path = Format::FileUri.extract_path(request.param("textDocument", "uri"))
      line = request.param("position", "line")
      column = request.param("position", "character")

      ::Holistic::Document::Cursor.new(file_path:, line:, column:)
    end

    def respond_with_location_link(request, origin, target)
      origin_location = origin.locations.first
      target_location = target.locations.first

      location_link = {
        "originSelectionRange" => {
          "start" => { "line" => origin_location.start_line, "character" => origin_location.start_column },
          "end" => { "line" => origin_location.end_line, "character" => origin_location.end_column }
        },
        "targetUri" => Format::FileUri.from_path(target_location.file_path),
        "targetRange" => {
          "start" => { "line" => target_location.start_line, "character" => target_location.start_column },
          "end" => { "line" => target_location.end_line, "character" => target_location.end_column }
        },
        # TODO: store the location of the declaration name
        "targetSelectionRange" => {
          "start" => { "line" => target_location.start_line, "character" => target_location.start_column },
          "end" => { "line" => target_location.end_line, "character" => target_location.end_column }
        }
      }

      request.respond_with([location_link])
    end
  end
end