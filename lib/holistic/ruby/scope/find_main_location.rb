# frozen_string_literal: true

module Holistic::Ruby::Scope
  module FindMainLocation
    extend self

    def call(scope:)
      location_matching_scope_name(scope) || scope.locations.first
    end

    private

    def location_matching_scope_name(scope)
      scope_name_in_snake_case = scope.name.underscore

      scope.locations.find do |location|
        ::File.basename(location.file_path) == "#{scope_name_in_snake_case}.rb"
      end
    end
  end
end
