# frozen_string_literal: true

module Question::Ruby
  module Namespace::Symbol
    ToRecord = ->(namespace) do
      Symbol::Record.new(
        identifier: namespace.fully_qualified_name,
        kind: :namespace,
        record: namespace,
        source_locations: namespace.source_locations
      )
    end

    Index = ->(application, namespace) do
      application.symbol_index.index(ToRecord[namespace])

      namespace.children.each(&Index.curry[application])
    end
  end
end
