# frozen_string_literal: true

module Holistic::LanguageServer
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_definition
  module Requests::TextDocument::GoToDefinition
    extend self

    def call(message)
      application = Current.application
      cursor = build_cursor_from_message_params(message)

      case ::Holistic::Ruby::Symbol::FindDefinition.call(application:, cursor:)
      in :not_found                              then respond_with_nil(message)
      in [:symbol_is_not_reference, {origin:}]   then respond_with_nil(message)
      in [:could_not_find_definition, {origin:}] then respond_with_nil(message)
      in [:definition_found, {origin:, target:}] then respond_with_location_link(message, origin, target)
      end
    end

    private

    def respond_with_nil(message)
      Response.in_reply_to(message).with(result: nil)
    end

    def respond_with_location_link(message, origin, target)
      origin_location = origin.locations.first
      target_location = target.locations.first

      location_link = {
        "originSelectionRange" => {
          "start" => { "line" => origin_location.start_line, "character" => origin_location.start_column },
          "end" => { "line" => origin_location.end_line, "character" => origin_location.end_column }
        },
        "targetUri" => "file://#{target_location.file_path}",
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

      Response.in_reply_to(message).with(result: [location_link])
    end

    def build_cursor_from_message_params(message)
      file_path = message.param("textDocument", "uri").gsub("file://", "")
      line = message.param("position", "line")
      column = message.param("position", "column")

      ::Holistic::Document::Cursor.new(file_path:, line:, column:)
    end
  end
end