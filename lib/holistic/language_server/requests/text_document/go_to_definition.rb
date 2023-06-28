# frozen_string_literal: true

module Holistic::LanguageServer
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_definition
  module Requests::TextDocument::GoToDefinition
    extend self

    def call(message)
      application = Current.application
      cursor = build_cursor_from_message_params(message)

      case ::Holistic::Ruby::Symbol::FindDeclarationUnderCursor.call(application:, cursor:)
      in :not_found                            then respond_with_nil(message)
      in [:symbol_is_not_reference, symbol]    then respond_with_nil(message)
      in [:could_not_find_declaration, symbol] then respond_with_nil(message)
      in [:declaration_found, declaration]     then raise "todo"
      end
    end

    private

    def respond_with_nil(message)
      Response.in_reply_to(message).with(result: nil)
    end

    def build_cursor_from_message_params(message)
      file_path = message.param("textDocument", "uri").delete("file://")
      line = message.param("position", "line")
      column = message.param("position", "column")

      ::Holistic::Document::Cursor.new(file_path:, line:, column:)
    end
  end
end