# frozen_string_literal: true

module Holistic::Ruby::Symbol
  # TODO: rename to `FindDefinitionUnderCursor` or just `FindDefinition`
  module FindDeclarationUnderCursor
    extend self

    def call(application:, cursor:)
      origin = application.symbols.find_by_cursor(cursor)

      return :not_found                               if origin.nil?
      return [:symbol_is_not_reference, {origin:}]    if origin.kind != Kind::REFERENCE
      return [:could_not_find_declaration, {origin:}] if origin.record.conclusion.nil?

      target = application.symbols.find(origin.record.conclusion.dependency_identifier)

      [:declaration_found, {origin:, target:}]
    end
  end
end
