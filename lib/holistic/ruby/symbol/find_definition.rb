# frozen_string_literal: true

module Holistic::Ruby::Symbol
  module FindDefinition
    extend self

    def call(application:, cursor:)
      origin = application.symbols.find_by_cursor(cursor)

      return :not_found                              if origin.nil?
      return [:origin_is_not_a_reference, {origin:}] if origin.kind != Kind::REFERENCE
      return [:could_not_find_definition, {origin:}] if origin.record.conclusion.nil?

      target = application.symbols.find(origin.record.conclusion.dependency_identifier)

      [:definition_found, {origin:, target:}]
    end
  end
end
