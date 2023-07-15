# frozen_string_literal: true

module Holistic::LanguageServer
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#exit
  module Requests::Lifecycle::Exit
    extend self

    def call(_request) = Response::Exit.new
  end
end
