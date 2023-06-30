# frozen_string_literal: true

module Holistic::LanguageServer
  module Requests::TextDocument::DidOpen
    extend self

    def call(request)
      path = request.message.param("textDocument", "uri").gsub("file://", "")
      content = request.message.param("textDocument", "text")

      request.application.documents.add(path:, content:)

      request.respond_with(nil)
    end
  end
end
