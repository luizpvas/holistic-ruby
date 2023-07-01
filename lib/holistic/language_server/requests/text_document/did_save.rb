# frozen_string_literal: true

module Holistic::LanguageServer
  module Requests::TextDocument::DidSave
    extend self

    ProcessInBackground = ->(application:, file:) do
      ::Thread.new do
        ::Holistic::Ruby::Parser::LiveEditing::ProcessFileChanged.call(application:, file:)
      end
    end

    def call(request)
      file_path = Format::FileUri.extract_path(request.param("textDocument", "uri"))
      unsaved_document = request.application.unsaved_documents.find(file_path)

      if unsaved_document.nil?
        return request.respond_with_error(
          code: Protocol::REQUEST_FAILED_ERROR_CODE,
          description: "could not find document #{file_path} in the unsaved documents list"
        )
      end

      ProcessInBackground.call(application: request.application, file: unsaved_document.to_file)

      request.respond_with(nil)
    end
  end
end
