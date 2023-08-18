# frozen_string_literal: true

module Holistic::LanguageServer::Requests
  module TextDocument::Completion
    extend self

    def call(request)
      request.respond_with(nil)
    end
  end
end
