# frozen_string_literal: true

module Holistic::Ruby::Namespace::Delete
  extend self

  def call(namespace:, file_path:)
    updated_locations = namespace.locations.reject! { |location| location.file_path == file_path }

    if updated_locations.nil?
      raise ::ArgumentError, "Namespace is not defined in the file path"
    end

    if namespace.locations.empty?
      namespace.parent.children.delete(namespace) 
    end
  end
end
