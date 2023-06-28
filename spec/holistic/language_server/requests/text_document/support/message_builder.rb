# frozen_string_literal: true

module MessageBuilder
  def build_definition_message_for(cursor:)
    data = {
      "jsonrpc" => ::Holistic::LanguageServer::Protocol::JSONRPC_VERSION,
      "id" => rand(1..10000),
      "method" => "textDocument/definition",
      "params" => {
        "position" => {
          "line" => cursor.line,
          "column" => cursor.column
        },
        "textDocument" => {
          "uri" => "file://#{cursor.file_path}"
        }
      }
    }

    ::Holistic::LanguageServer::Message.new(data:)
  end
end
