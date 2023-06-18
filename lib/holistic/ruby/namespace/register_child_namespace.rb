# frozen_string_literal: true

module Holistic::Ruby::Namespace
  module RegisterChildNamespace
    extend self

    def call(parent:, kind:, name:, source_location:)
      append_source_location_to_existing_namespace(namespace: parent, name:, source_location:) || add_new_namespace(parent:, kind:, name:, source_location:)
    end

    private

    def append_source_location_to_existing_namespace(namespace:, name:, source_location:)
      child_namespace = namespace.children.find { _1.name == name }

      return if child_namespace.nil?

      child_namespace.tap { _1.source_locations << source_location }
    end

    def add_new_namespace(parent:, kind:, name:, source_location:)
      child_namespace = Record.new(kind:, name:, parent:, source_location:)

      child_namespace.tap { parent.children << _1 }
    end
  end
end