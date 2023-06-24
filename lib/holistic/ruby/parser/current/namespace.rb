# frozen_string_literal: true

module Holistic::Ruby::Parser
  module Current::Namespace
    extend self

    def register_child_module(namespace_declaration:, source_location:, &block)
      starting_namespace = Current.namespace

      namespace_declaration.each do |name|
        Current.namespace = ::Holistic::Ruby::Namespace::RegisterChildNamespace.call(parent: Current.namespace, kind: ::Holistic::Ruby::Namespace::Kind::MODULE, name:, source_location:)

        Current.registration_queue.register(Current.namespace.to_symbol)
      end

      Current.constant_resolution_possibilities.unshift(namespace_declaration.to_s)

      block.call

      Current.namespace = starting_namespace
      Current.constant_resolution_possibilities.shift
    end

    def register_child_class(namespace_declaration:, source_location:, &block)
      starting_namespace = Current.namespace

      namespace_declaration.each do |name|
        Current.namespace = ::Holistic::Ruby::Namespace::RegisterChildNamespace.call(parent: Current.namespace, kind: ::Holistic::Ruby::Namespace::Kind::CLASS, name:, source_location:)

        Current.registration_queue.register(Current.namespace.to_symbol)
      end

      Current.constant_resolution_possibilities.unshift(namespace_declaration.to_s)

      block.call

      Current.namespace = starting_namespace
      Current.constant_resolution_possibilities.shift
    end
  end
end
