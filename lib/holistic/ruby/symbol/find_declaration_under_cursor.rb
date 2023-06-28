# frozen_string_literal: true

module Holistic::Ruby::Symbol
  module FindDeclarationUnderCursor
    extend self

    def call(application:, cursor:)
      symbol = application.symbols.find_by_cursor(cursor)

      return :not_found                            if symbol.nil?
      return [:symbol_is_not_reference, symbol]    if symbol.kind != Kind::REFERENCE
      return [:could_not_find_declaration, symbol] if symbol.record.conclusion.nil?

      declaration = application.symbols.find(symbol.record.conclusion.dependency_identifier)

      [:declaration_found, declaration]
    end
  end
end
