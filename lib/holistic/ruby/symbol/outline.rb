# frozen_string_literal: true

module Holistic::Ruby::Symbol
  module Outline
    extend self

    Result = ::Struct.new(
      :declarations,
      :dependencies,
      :references,
      :dependants,
      keyword_init: true
    )

    def call(application:, symbol:)
      references = application.dependencies.list_references(dependency_identifier: symbol.identifier)

      Result.new(
        declarations: [],
        dependencies: [],
        references:,
        dependants: []
      )
    end
  end
end
