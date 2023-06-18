# frozen_string_literal: true

module Holistic::Ruby::Symbol
  module Outline
    extend self

    Result = ::Struct.new(
      :declarations,
      :dependencies,
      :dependants,
      keyword_init: true
    )

    def call(application:, symbol:)
      dependants = application.dependencies.list_dependants(dependency_identifier: symbol.identifier)

      Result.new(
        declarations: [],
        dependencies: [],
        dependants:
      )
    end
  end
end
