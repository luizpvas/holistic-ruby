# frozen_string_literal: true

module Holistic::LanguageServer
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#exit
  module Requests::Lifecycle::Exit
    extend self

    # TODO: The server should exit with success code 0 if the shutdown request has been received before; otherwise with error code 1

    def call(_message) = Response::Exit.new
  end
end
