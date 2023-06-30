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
      file_path = request.param("textDocument", "uri").gsub("file://", "")
      unsaved_document = request.application.unsaved_documents.find(file_path)

      # TODO: perhaps we should have something like `request.respond_with_error`
      return request.respond_with(nil) if unsaved_document.nil?

      ProcessInBackground.call(application: request.application, file: unsaved_document.to_file)

      request.respond_with(nil)
    end
  end
end
