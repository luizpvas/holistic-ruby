# frozen_string_literal: true

module Holistic::Extensions::Ruby
  module Stdlib
    extend self

    ResolveClassConstructor = ->(application, params) do
      method_call_clue, referenced_scope = params[:method_call_clue], params[:referenced_scope]

      if method_call_clue.method_name == "new" && referenced_scope.class?
        initialize_method = "#{referenced_scope.fully_qualified_name}#initialize"

        return application.scopes.find(initialize_method)
      end

      nil
    end

    RegisterClassConstructor = ->(application, params) do
      class_scope, location = params[:class_scope], params[:location]

      has_overridden_new_method = class_scope.children.find { _1.instance_method? && _1.name == "initialize" }

      unless has_overridden_new_method
        ::Holistic::Ruby::Scope::Store.call(
          database: application.database,
          parent: class_scope,
          kind: ::Holistic::Ruby::Scope::Kind::CLASS_METHOD,
          name: "new",
          location:
        )
      end
    end

    LAMBDA_METHODS = ["call", "curry"].freeze

    RegisterLambdaMethods = ->(application, params) do
      lambda_scope, location = params[:lambda_scope], params[:location]

      LAMBDA_METHODS.each do |method_name|
        ::Holistic::Ruby::Scope::Store.call(
          database: application.database,
          parent: lambda_scope,
          kind: ::Holistic::Ruby::Scope::Kind::CLASS_METHOD,
          name: method_name,
          location:
        )
      end
    end

    def register(application)
      application.extensions.bind(:resolve_method_call_known_scope, &ResolveClassConstructor.curry[application])
      application.extensions.bind(:class_scope_registered,          &RegisterClassConstructor.curry[application])
      application.extensions.bind(:lambda_scope_registered,         &RegisterLambdaMethods.curry[application])
    end
  end
end
