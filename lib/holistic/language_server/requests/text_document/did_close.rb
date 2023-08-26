# frozen_string_literal: true

module Holistic::LanguageServer
  module Requests::TextDocument::DidClose
    extend self

    def call(request)
      path = Format::FileUri.extract_path(request.message.param("textDocument", "uri"))

      request.application.unsaved_documents.find(path)&.then do |unsaved_document|
        request.application.unsaved_documents.delete(path)
        
        if unsaved_document.has_unsaved_changes?
          unsaved_document.restore_original_content!

          ::Holistic::Ruby::Parser::LiveEditing::ProcessFileChanged.call(
            application: request.application,
            file_path: unsaved_document.path,
            content: unsaved_document.content
          )
        end
      end

      request.respond_with(nil)
    end
  end
end
