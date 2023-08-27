# frozen_string_literal: true

module Holistic::Ruby::Reference
  Record = ::Struct.new(
    :scope,
    :clues,
    :location,
    :referenced_scope,

    # TODO: delete
    :conclusion,
    
    keyword_init: true
  ) do
    def identifier = location.identifier

    concerning :ReferencedScopeConnection do
      def connect_referenced_scope(referenced_scope)
        self.referenced_scope = referenced_scope
      end

      def disconnect_referenced_scope
        self.referenced_scope = nil
      end
    end
  end
end
