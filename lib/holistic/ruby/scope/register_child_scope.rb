# frozen_string_literal: true

module Holistic::Ruby::Scope
  module RegisterChildScope
    extend self

    def call(parent:, kind:, name:, location:)
      append_location_to_existing_scope(scope: parent, name:, location:) || add_new_scope(parent:, kind:, name:, location:)
    end

    private

    def append_location_to_existing_scope(scope:, name:, location:)
      child_scope = scope.children.find { _1.name == name }

      return if child_scope.nil?

      child_scope.tap { _1.locations << location }
    end

    def add_new_scope(parent:, kind:, name:, location:)
      child_scope = Record.new(kind:, name:, parent:, location:)

      child_scope.tap { parent.children << _1 }
    end
  end
end