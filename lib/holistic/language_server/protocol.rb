# frozen_string_literal: true

module Holistic::LanguageServer::Protocol
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#abstractMessage
  JSONRPC_VERSION = "2.0"

  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#headerPart
  END_OF_HEADER = "\r\n\r\n"
  CONTENT_LENGTH_HEADER = "Content-Length"
end