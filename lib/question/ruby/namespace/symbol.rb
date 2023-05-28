# frozen_string_literal: true

module Question::Ruby
  module Namespace::Symbol
    ToEntity = ->(namespace) do
      Symbol::Entity.new(
        identifier: namespace.fully_qualified_name,
        kind: :namespace,
        record: namespace,
        source_locations: namespace.source_locations
      )
    end

    Index = ->(application, namespace) do
      application.symbol_index.index(ToEntity[namespace])

      namespace.children.each(&Index.curry[application])
    end
  end
end
