# frozen_string_literal: true

module Holistic::LanguageServer::Protocol
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#abstractMessage
  JSONRPC_VERSION = "2.0"

  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#headerPart
  END_OF_HEADER = "\r\n\r\n"
  CONTENT_LENGTH_HEADER = "Content-Length"

  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_synchronization
  INCREMENTAL_TEXT_DOCUMENT_SYNCHRONIZATION = 2

  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#responseMessage
  REQUEST_FAILED_ERROR_CODE         = -32803
  INVALID_REQUEST_ERROR_CODE        = -32600
  SERVER_NOT_INITIALIZED_ERROR_CODE = -32002
end