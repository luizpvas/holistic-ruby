# frozen_string_literal: true

module Question::Ruby::Parser
  module Current::Namespace
    extend self

    def nest_module(name:, source_location:, &block)
      Current.namespace = Current.namespace.nest(kind: :module, name:, source_location:)
      Current.resolution.unshift(name)

      block.call

      Current.namespace = Current.namespace.parent
      Current.resolution.shift
    end

    def nest_class(name:, source_location:, &block)
      Current.namespace = Current.namespace.nest(kind: :class, name:, source_location:)
      Current.resolution.unshift(name)

      block.call

      Current.namespace = Current.namespace.parent
      Current.resolution.shift
    end
  end
end
