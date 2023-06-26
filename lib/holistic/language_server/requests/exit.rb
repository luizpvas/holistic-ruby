# frozen_string_literal: true

module Holistic::LanguageServer
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#exit
  module Requests::Exit
    extend self

    # TODO: add spec
    # TODO: The server should exit with success code 0 if the shutdown request has been received before; otherwise with error code 1

    def call(_message) = Response.exit
  end
end