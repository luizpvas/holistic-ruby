# frozen_string_literal: true

module Support
  module LanguageServer
    module Factory
      def build_initialize_message(root_directory:)
        data = {
          "jsonrpc" => ::Holistic::LanguageServer::Protocol::JSONRPC_VERSION,
          "id" => rand(1..10000),
          "method" => "initialize",
          "params" => {
            "capabilities" => {},
            "rootPath" => root_directory
          }
        }

        ::Holistic::LanguageServer::Message.new(data:)
      end

      def build_definition_message(file_path:, line:, column:)
        data = {
          "jsonrpc" => ::Holistic::LanguageServer::Protocol::JSONRPC_VERSION,
          "id" => rand(1..10000),
          "method" => "textDocument/definition",
          "params" => {
            "position" => {
              "line" => line,
              "character" => column
            },
            "textDocument" => {
              "uri" => "file://#{file_path}"
            }
          }
        }

        ::Holistic::LanguageServer::Message.new(data:)
      end

      def build_references_message(file_path:, line:, column:)
        data = {
          "jsonrpc" => ::Holistic::LanguageServer::Protocol::JSONRPC_VERSION,
          "id" => rand(1..10000),
          "method" => "textDocument/references",
          "params" => {
            "position" => {
              "line" => line,
              "character" => column
            },
            "textDocument" => {
              "uri" => "file://#{file_path}"
            }
          }
        }

        ::Holistic::LanguageServer::Message.new(data:)
      end

      def build_completion_message(file_path:, line:, column:)
        data = {
          "jsonrpc" => ::Holistic::LanguageServer::Protocol::JSONRPC_VERSION,
          "id" => rand(1..10000),
          "method" => "textDocument/completion",
          "params" => {
            "position" => {
              "line" => line,
              "character" => column
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
end