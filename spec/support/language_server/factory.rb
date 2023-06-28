# frozen_string_literal: true

module LanguageServer
  module Factory
    extend self

    def build_definition_message(file_path:, line:, column:)
      data = {
        "jsonrpc" => ::Holistic::LanguageServer::Protocol::JSONRPC_VERSION,
        "id" => rand(1..10000),
        "method" => "textDocument/definition",
        "params" => {
          "position" => {
            "line" => line,
            "column" => column
          },
          "textDocument" => {
            "uri" => "file://#{file_path}"
          }
        }
      }

      ::Holistic::LanguageServer::Message.new(data:)
    end
  end
end