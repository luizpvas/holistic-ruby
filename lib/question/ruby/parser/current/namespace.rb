# frozen_string_literal: true

module Question::Ruby::Parser
  module Current::Namespace
    extend self

    def nest_module(namespace_declaration:, source_location:, &block)
      starting_namespace = Current.namespace

      namespace_declaration.each do |name|
        Current.namespace = Current.namespace.nest(kind: :module, name:, source_location:)
      end

      Current.resolution.unshift(namespace_declaration.to_s)

      block.call

      Current.namespace = starting_namespace
      Current.resolution.shift
    end

    def nest_class(namespace_declaration:, source_location:, &block)
      starting_namespace = Current.namespace

      namespace_declaration.each do |name|
        Current.namespace = Current.namespace.nest(kind: :class, name:, source_location:)
      end

      Current.resolution.unshift(namespace_declaration.to_s)

      block.call

      Current.namespace = starting_namespace
      Current.resolution.shift
    end
  end
end
