# frozen_string_literal: true

module Holistic::Ruby
  module Namespace
    ToSymbol = ->(namespace) do
      Symbol::Record.new(
        identifier: namespace.fully_qualified_name,
        kind: :namespace,
        record: namespace,
        source_locations: namespace.source_locations,
        searchable?: true
      )
    end
  end
end
