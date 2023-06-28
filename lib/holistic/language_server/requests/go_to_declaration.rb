# frozen_string_literal: true

module Holistic::LanguageServer
  # https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_declaration
  module Requests::GoToDeclaration
    extend self

    def call!(message)
      raise "todo"
    end
  end
end