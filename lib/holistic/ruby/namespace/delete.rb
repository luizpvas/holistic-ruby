# frozen_string_literal: true

module Holistic::Ruby::Namespace::Delete
  extend self

  def call(namespace:, file_path:)
    updated_source_locations = namespace.source_locations.reject! { |source_location| source_location.file_path == file_path }

    if updated_source_locations.nil?
      raise ::ArgumentError, "Namespace is not defined in the file path"
    end

    if namespace.source_locations.empty?
      namespace.parent.children.delete(namespace) 
    end
  end
end
