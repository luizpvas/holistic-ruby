# frozen_string_literal: true

module Holistic::Ruby::Scope
  module ListReferences
    extend self

    def call(application:, cursor:)
      scope = application.scopes.find_by_cursor(cursor)

      return :not_found if scope.nil?

      references = application.references.list_references_to(scope.fully_qualified_name)

      [:references_listed, {references:}]
    end
  end
end