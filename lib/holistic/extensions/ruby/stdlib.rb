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

    LAMBDA_METHODS = ["call", "curry"]

    RegisterLambdaMethods = ->(application, params) do
      lambda_scope = params[:lambda_scope]

      LAMBDA_METHODS.each do |method_name|
        ::Holistic::Ruby::Scope::Register.call(
          repository: application.scopes,
          parent: lambda_scope,
          kind: ::Holistic::Ruby::Scope::Kind::CLASS_METHOD,
          name: method_name,
          location: lambda_scope.locations.items.first
        )
      end
    end

    def register(application)
      application.extensions.bind(:resolve_method_call_known_scope, &ResolveClassConstructor.curry[application])
      application.extensions.bind(:lambda_scope_registered, &RegisterLambdaMethods.curry[application])
    end
  end
end
