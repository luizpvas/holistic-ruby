# frozen_string_literal: true

module Holistic::LanguageServer
  module Requests::TextDocument::DidSave
    extend self

    def call(request)
      file_path = Format::FileUri.extract_path(request.param("textDocument", "uri"))
      unsaved_document = request.application.unsaved_documents.find(file_path)

      if unsaved_document.nil?
        return request.respond_with_error(
          code: Protocol::REQUEST_FAILED_ERROR_CODE,
          description: "could not find document #{file_path} in the unsaved documents list"
        )
      end

      unsaved_document.mark_as_saved!

      ::Holistic::Ruby::Parser::LiveEditing::ProcessFileChanged.call(
        application: request.application,
        file_path: unsaved_document.path,
        content: unsaved_document.content
      )

      request.drop
    end
  end
end
