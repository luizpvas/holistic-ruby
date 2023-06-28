# frozen_string_literal: true

module Holistic::Ruby::Namespace
  module RegisterChildNamespace
    extend self

    def call(parent:, kind:, name:, location:)
      append_location_to_existing_namespace(namespace: parent, name:, location:) || add_new_namespace(parent:, kind:, name:, location:)
    end

    private

    def append_location_to_existing_namespace(namespace:, name:, location:)
      child_namespace = namespace.children.find { _1.name == name }

      return if child_namespace.nil?

      child_namespace.tap { _1.locations << location }
    end

    def add_new_namespace(parent:, kind:, name:, location:)
      child_namespace = Record.new(kind:, name:, parent:, location:)

      child_namespace.tap { parent.children << _1 }
    end
  end
end