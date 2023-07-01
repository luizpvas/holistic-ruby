# frozen_string_literal: true

module Holistic::LanguageServer
  module Requests::TextDocument::DidOpen
    extend self

    def call(request)
      path = Format::FileUri.extract_path(request.message.param("textDocument", "uri"))
      content = request.message.param("textDocument", "text")

      request.application.unsaved_documents.add(path:, content:)

      request.respond_with(nil)
    end
  end
end
