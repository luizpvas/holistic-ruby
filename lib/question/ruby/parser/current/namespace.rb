# frozen_string_literal: true

module Question::Ruby::Parser
  # TODO: The tree structure should have one record per module/class. Even with the collapsed
  # syntax (e.g. `MyApp::MyModule`) we should end up with two records where `MyModule` is
  # a child of `MyApp`.
  module Current::Namespace
    extend self

    def nest_module(name_path:, source_location:, &block)
      starting_namespace = Current.namespace

      name_path.each do |name|
        Current.namespace = Current.namespace.nest(kind: :module, name:, source_location:)
      end

      Current.resolution.unshift(name_path.to_s)

      block.call

      Current.namespace = starting_namespace
      Current.resolution.shift
    end

    def nest_class(name_path:, source_location:, &block)
      starting_namespace = Current.namespace

      name_path.each do |name|
        Current.namespace = Current.namespace.nest(kind: :class, name:, source_location:)
      end

      Current.resolution.unshift(name_path.to_s)

      block.call

      Current.namespace = starting_namespace
      Current.resolution.shift
    end
  end
end
