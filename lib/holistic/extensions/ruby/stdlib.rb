# frozen_string_literal: true

module Holistic::Extensions::Ruby
  module Stdlib
    extend self

    ResolveClassConstructor = ->(application:, reference:, referenced_scope:, method_call_clue:) do
      if method_call_clue.method_name == "new" && referenced_scope.class?
        initialize_method = "#{referenced_scope.fully_qualified_name}#initialize"

        return application.scopes.find_by_fully_qualified_name(initialize_method)
      end

      nil
    end

    ResolveClassMethods = ->(application:, reference:, referenced_scope:, method_call_clue:) do
      self_method_name = "#{referenced_scope.fully_qualified_name}#self.#{method_call_clue.method_name}"

      application.scopes.find_by_fully_qualified_name(self_method_name)
    end

    def register(application)
      application.extensions.bind(:resolve_method_call_known_scope, &ResolveClassConstructor)
      application.extensions.bind(:resolve_method_call_known_scope, &ResolveClassMethods)
    end
  end
end
