# frozen_string_literal: true

module Holistic::Ruby::Scope
  module UnregisterDefinition
    extend self

    def call(repository:, fully_qualified_name:, file_path:)
      scope = repository.find_by_fully_qualified_name(fully_qualified_name)

      return :scope_not_found if scope.nil?

      updated_locations = scope.locations.reject! { |location| location.file_path == file_path }

      return :scope_not_defined_in_speciefied_file if updated_locations.nil?

      if updated_locations.empty?
        scope.parent.children.delete(scope)

        repository.delete_by_fully_qualified_name(fully_qualified_name)
      else
        repository.register_scope(scope)
      end

      :definition_unregistered
    end
  end
end
