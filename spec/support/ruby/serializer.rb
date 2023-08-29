# frozen_string_literal: true

module Support
  module Ruby
    module Serializer
      def serialize_scope(scope)
        nested = {}
        root = {scope.name => nested}

        scope.has_many(:children).each do |child|
          nested.merge!(serialize_scope(child))
        end

        root
      end
    end
  end
end
