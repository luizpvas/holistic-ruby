# frozen_string_literal: true

module Holistic::Ruby::Scope::Delete
  extend self

  def call(scope:, file_path:)
    updated_locations = scope.locations.reject! { |location| location.file_path == file_path }

    if updated_locations.nil?
      raise ::ArgumentError, "Scope is not defined in the file path"
    end

    if scope.locations.empty?
      scope.parent.children.delete(scope)
    end
  end
end
