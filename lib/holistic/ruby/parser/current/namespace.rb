# frozen_string_literal: true

module Holistic::Ruby::Parser
  module Current::Namespace
    extend self

    # TODO: I'm not liking the usage of the `nest` word here. We are registering the namespace under the
    # current namespace.

    def nest_module(namespace_declaration:, source_location:, &block)
      starting_namespace = Current.namespace

      namespace_declaration.each do |name|
        Current.namespace = ::Holistic::Ruby::Namespace::RegisterChildNamespace.call(parent: Current.namespace, kind: :module, name:, source_location:)

        Current.registration_queue.register(::Holistic::Ruby::Namespace::ToSymbol[Current.namespace])
      end

      Current.constant_resolution_possibilities.unshift(namespace_declaration.to_s)

      block.call

      Current.namespace = starting_namespace
      Current.constant_resolution_possibilities.shift
    end

    def nest_class(namespace_declaration:, source_location:, &block)
      starting_namespace = Current.namespace

      namespace_declaration.each do |name|
        Current.namespace = ::Holistic::Ruby::Namespace::RegisterChildNamespace.call(parent: Current.namespace, kind: :class, name:, source_location:)

        Current.registration_queue.register(::Holistic::Ruby::Namespace::ToSymbol[Current.namespace])
      end

      Current.constant_resolution_possibilities.unshift(namespace_declaration.to_s)

      block.call

      Current.namespace = starting_namespace
      Current.constant_resolution_possibilities.shift
    end
  end
end
