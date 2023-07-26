# frozen_string_literal: true

module Holistic::Ruby::Parser
  module Current::Scope
    extend self

    def register_child_module(nesting:, location:, &block)
      starting_scope = Current.scope

      nesting.each do |name|
        Current.scope =
          ::Holistic::Ruby::Scope::Register.call(
            repository: Current.application.scopes,
            parent: Current.scope,
            kind: ::Holistic::Ruby::Scope::Kind::MODULE,
            name:,
            location:
          )
      end

      Current.constant_resolution_possibilities.unshift(Current.scope.fully_qualified_name)

      block.call

      Current.scope = starting_scope
      Current.constant_resolution_possibilities.shift
    end

    def register_child_class(nesting:, location:, &block)
      starting_scope = Current.scope

      nesting.each do |name|
        Current.scope =
          ::Holistic::Ruby::Scope::Register.call(
            repository: Current.application.scopes,
            parent: Current.scope,
            kind: ::Holistic::Ruby::Scope::Kind::CLASS,
            name:,
            location:
          )
      end

      Current.constant_resolution_possibilities.unshift(Current.scope.fully_qualified_name)

      block.call

      Current.scope = starting_scope
      Current.constant_resolution_possibilities.shift
    end
  end
end
