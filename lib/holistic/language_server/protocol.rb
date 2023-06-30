# frozen_string_literal: true

module Holistic::LanguageServer::Protocol
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#abstractMessage
  JSONRPC_VERSION = "2.0"

  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#headerPart
  END_OF_HEADER = "\r\n\r\n"
  CONTENT_LENGTH_HEADER = "Content-Length"

  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_synchronization
  INCREMENTAL_TEXT_DOCUMENT_SYNCHRONIZATION = 2

  # A request failed but it was syntactically correct, e.g the
  # method name was known and the parameters were valid. The error
  # message should contain human readable information about why
  # the request failed.
  REQUEST_FAILED_ERROR_CODE = -32803
end