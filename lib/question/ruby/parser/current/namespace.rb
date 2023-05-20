# frozen_string_literal: true

module Question::Ruby::Parser
  # TODO: The tree structure should have one record per module/class. Even with the collapsed
  # syntax (e.g. `MyApp::MyModule`) we should end up with two records where `MyModule` is
  # a child of `MyApp`.
  module Current::Namespace
    extend self

    def nest_module(name_path:, source_location:, &block)
      Current.namespace = Current.namespace.nest(kind: :module, name: name_path.to_s, source_location:)
      Current.resolution.unshift(name_path.to_s)

      block.call

      Current.namespace = Current.namespace.parent
      Current.resolution.shift
    end

    def nest_class(name_path:, source_location:, &block)
      Current.namespace = Current.namespace.nest(kind: :class, name: name_path.to_s, source_location:)
      Current.resolution.unshift(name_path.to_s)

      block.call

      Current.namespace = Current.namespace.parent
      Current.resolution.shift
    end
  end
end
