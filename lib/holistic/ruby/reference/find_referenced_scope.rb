# frozen_string_literal: true

module Holistic::Ruby::Reference
  module FindReferencedScope
    extend self

    def call(application:, cursor:)
      reference = application.references.find_by_cursor(cursor)

      ::Holistic.logger.info("reference: #{reference.inspect}")

      return :not_found if reference.nil?

      ::Holistic.logger.info("clues: #{reference.clues}")

      return :could_not_find_referenced_scope if reference.referenced_scope.nil?

      referenced_scope = reference.referenced_scope

      [:referenced_scope_found, {reference:, referenced_scope:}]
    end
  end
end
