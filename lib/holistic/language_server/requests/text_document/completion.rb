# frozen_string_literal: true

module Holistic::LanguageServer
  module Requests::TextDocument::Completion
    extend self

    def call(request)
      cursor = build_cursor_from_request_params(request)

      document = request.application.unsaved_documents.find(cursor.file_path)

      return request.respond_with(nil) if document.nil?

      if document.has_unsaved_changes?
        ::Holistic::Ruby::Parser::LiveEditing::ProcessFileChanged.call(
          application: request.application,
          file: document.to_file
        )
      end

      code = document.expand_code(cursor)
      scope = request.application.scopes.find_inner_most_scope_by_cursor(cursor) || request.application.root_scope

      return request.respond_with(nil) if code.blank?

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

    module CompletionKind
      FROM_SCOPE_TO_COMPLETION = {
        ::Holistic::Ruby::Scope::Kind::CLASS  => Protocol::COMPLETION_ITEM_KIND_CLASS,
        ::Holistic::Ruby::Scope::Kind::LAMBDA => Protocol::COMPLETION_ITEM_KIND_FUNCTION,
        ::Holistic::Ruby::Scope::Kind::METHOD => Protocol::COMPLETION_ITEM_KIND_METHOD,
        ::Holistic::Ruby::Scope::Kind::MODULE => Protocol::COMPLETION_ITEM_KIND_MODULE,
        ::Holistic::Ruby::Scope::Kind::ROOT   => Protocol::COMPLETION_ITEM_KIND_MODULE
      }.freeze

      DEFAULT = Protocol::COMPLETION_ITEM_KIND_MODULE

      def self.fetch(scope_kind)
        FROM_SCOPE_TO_COMPLETION.fetch(scope_kind, DEFAULT)
      end
    end

    def respond_with_suggestions(request, suggestions)
      formatted_suggestions = suggestions.map do |suggestion|
        {
          label: suggestion.code,
          kind: CompletionKind.fetch(suggestion.kind)
        }
      end

      request.respond_with(formatted_suggestions)
    end
  end
end
