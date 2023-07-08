# frozen_string_literal: true

module Holistic::Ruby::Parser
  module Current::Scope
    extend self

    def register_child_module(nesting:, location:, &block)
      starting_scope = Current.scope

      nesting.each do |name|
        Current.scope =
          ::Holistic::Ruby::Scope::RegisterChildScope.call(
            repository: Current.application.scopes,
            parent: Current.scope,
            kind: ::Holistic::Ruby::Scope::Kind::MODULE,
            name:,
            location:
          )

        Current.registration_queue.register(Current.scope.to_symbol)
      end

      Current.constant_resolution_possibilities.unshift(nesting.to_s)

      block.call

      Current.scope = starting_scope
      Current.constant_resolution_possibilities.shift
    end

    def register_child_class(nesting:, location:, &block)
      starting_scope = Current.scope

      nesting.each do |name|
        Current.scope =
          ::Holistic::Ruby::Scope::RegisterChildScope.call(
            repository: Current.application.scopes,
            parent: Current.scope,
            kind: ::Holistic::Ruby::Scope::Kind::CLASS,
            name:,
            location:
          )

        Current.registration_queue.register(Current.scope.to_symbol)
      end

      Current.constant_resolution_possibilities.unshift(nesting.to_s)

      block.call

      Current.scope = starting_scope
      Current.constant_resolution_possibilities.shift
    end
  end
end
