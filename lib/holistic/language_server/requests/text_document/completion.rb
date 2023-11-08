# frozen_string_literal: true

module Holistic::LanguageServer
  module Requests::TextDocument::Completion
    extend self

    def call(request)
      cursor = build_cursor_from_request_params(request)

      document = request.application.unsaved_documents.find(cursor.file_path)

      if document.nil?
        ::Holistic.logger.info("aborting completion because document was not found for #{cursor.file_path}")

        return request.respond_with(nil) 
      end

      if document.has_unsaved_changes?
        ::Holistic::Ruby::Parser::LiveEditing::ProcessFileChanged.call(
          application: request.application,
          file_path: document.path,
          content: document.content
        )
      end

      piece_of_code = ::Holistic::Ruby::Autocompletion::PieceOfCode.new(document.expand_code(cursor))

      scope = request.application.scopes.find_inner_most_scope_by_cursor(cursor) || request.application.scopes.root

      suggestions = piece_of_code.suggester.suggest(scope:)

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
        ::Holistic::Ruby::Scope::Kind::CLASS           => Protocol::COMPLETION_ITEM_KIND_CLASS,
        ::Holistic::Ruby::Scope::Kind::LAMBDA          => Protocol::COMPLETION_ITEM_KIND_FUNCTION,
        ::Holistic::Ruby::Scope::Kind::CLASS_METHOD    => Protocol::COMPLETION_ITEM_KIND_METHOD,
        ::Holistic::Ruby::Scope::Kind::INSTANCE_METHOD => Protocol::COMPLETION_ITEM_KIND_METHOD,
        ::Holistic::Ruby::Scope::Kind::MODULE          => Protocol::COMPLETION_ITEM_KIND_MODULE,
        ::Holistic::Ruby::Scope::Kind::ROOT            => Protocol::COMPLETION_ITEM_KIND_MODULE
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
