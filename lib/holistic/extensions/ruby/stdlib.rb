# frozen_string_literal: true

module Holistic::Extensions::Ruby
  module Stdlib
    extend self

    ResolveClassConstructor = ->(application, params) do
      method_call_clue, referenced_scope = params[:method_call_clue], params[:referenced_scope]

      if method_call_clue.method_name == "new" && referenced_scope.class?
        initialize_method = "#{referenced_scope.fully_qualified_name}#initialize"

        return application.scopes.find_by_fully_qualified_name(initialize_method)
      end

      nil
    end

    ResolveStaticMethods = ->(application, params) do
      method_call_clue, referenced_scope = params[:method_call_clue], params[:referenced_scope]

      self_method_name = "#{referenced_scope.fully_qualified_name}#self.#{method_call_clue.method_name}"

      application.scopes.find_by_fully_qualified_name(self_method_name)
    end

    ResolveCallToLambda = ->(application, params) do
      method_call_clue, referenced_scope = params[:method_call_clue], params[:referenced_scope]

      if method_call_clue.method_name == "call" && referenced_scope.lambda?
        return referenced_scope
      end
    end

    def register(application)
      application.extensions.bind(:resolve_method_call_known_scope, &ResolveClassConstructor.curry[application])
      application.extensions.bind(:resolve_method_call_known_scope, &ResolveStaticMethods.curry[application])
      application.extensions.bind(:resolve_method_call_known_scope, &ResolveCallToLambda.curry[application])
    end
  end
end