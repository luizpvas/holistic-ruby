# frozen_string_literal: true

module Question::Ruby
  module Namespace
    ToSymbol = ->(namespace) do
      Symbol::Entity.new(
        identifier: namespace.fully_qualified_name,
        kind: :namespace,
        record: namespace,
        source_locations: namespace.source_locations
      )
    end
  end
end
