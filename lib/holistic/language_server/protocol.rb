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

  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#completionItemKind
  COMPLETION_ITEM_KIND_TEXT          = 1
  COMPLETION_ITEM_KIND_METHOD        = 2
  COMPLETION_ITEM_KIND_FUNCTION      = 3
  COMPLETION_ITEM_KIND_CONSTRUCTOR   = 4
  COMPLETION_ITEM_KIND_FIELD         = 5
  COMPLETION_ITEM_KIND_VARIABLE      = 6
  COMPLETION_ITEM_KIND_CLASS         = 7
  COMPLETION_ITEM_KIND_INTERFACE     = 8
  COMPLETION_ITEM_KIND_MODULE        = 9
  COMPLETION_ITEM_KIND_PROPERTY      = 10
  COMPLETION_ITEM_KIND_UNIT          = 11
  COMPLETION_ITEM_KIND_VALUE         = 12
  COMPLETION_ITEM_KIND_ENUM          = 13
  COMPLETION_ITEM_KIND_KEYWORD       = 14
  COMPLETION_ITEM_KIND_SNIPPET       = 15
  COMPLETION_ITEM_KIND_COLOR         = 16
  COMPLETION_ITEM_KIND_FILE          = 17
  COMPLETION_ITEM_KIND_REFERENCE     = 18
  COMPLETION_ITEM_KIND_FOLDER        = 19
  COMPLETION_ITEM_KIND_ENUM_MEMBER   = 20
  COMPLETION_ITEM_KIND_CONSTANT      = 21
  COMPLETION_ITEM_KIND_STRUCT        = 22
  COMPLETION_ITEM_KIND_EVENT         = 23
  COMPLETION_ITEM_KIND_OPERATOR      = 24
  COMPLETION_ITEM_KIND_TYPE_PARAMTER = 25
end