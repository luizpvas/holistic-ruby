# frozen_string_literal: true

module Holistic::LanguageServer
  module Requests::TextDocument::Completion
    extend self

    def call(request)
      cursor = build_cursor_from_request_params(request)

      scope = request.application.scopes.find_inner_most_scope_by_cursor(cursor) || request.application.root_scope

      document = request.application.unsaved_documents.find(cursor.file_path)

      return request.respond_with(nil) if document.nil?

      if document.has_unsaved_changes?
        ::Holistic::Ruby::Parser::LiveEditing::ProcessFileChanged.call(
          application: request.application,
          file: document.to_file
        )
      end

      code = document.expand_code(cursor)

      puts "root object_id: #{request.application.root_scope.object_id}"
      puts "myapp: #{request.application.root_scope.children.first.fully_qualified_name}"
      puts "myapp object_id: #{request.application.root_scope.children.first.object_id}"

      suggestions = ::Holistic::Ruby::Autocompletion::Suggest.call(code:, scope:)

      respond_with_suggestions(request, suggestions)
    end

    private

    def build_cursor_from_request_params(request)
      file_path = Format::FileUri.extract_path(request.param("textDocument", "uri"))
      line = request.param("position", "line")
      column = request.param("position", "character")

      ::Holistic::Document::Cursor.new(file_path:, line:, column:)
    end

    def respond_with_suggestions(request, suggestions)
      formatted_suggestions = suggestions.map do |suggestion|
        {
          label: suggestion.code
        }
      end

      request.respond_with(formatted_suggestions)
    end
  end
end
