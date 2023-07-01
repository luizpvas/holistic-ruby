# frozen_string_literal: true

module Holistic::LanguageServer
  module Requests::TextDocument::DidClose
    extend self

    def call(request)
      path = Format::FileUri.extract_path(request.message.param("textDocument", "uri"))

      request.application.unsaved_documents.delete(path)

      request.respond_with(nil)
    end
  end
end
