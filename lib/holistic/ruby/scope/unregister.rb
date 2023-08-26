# frozen_string_literal: true

module Holistic::Ruby::Scope
  module Unregister
    extend self

    def call(repository:, fully_qualified_name:, file_path:)
      scope = repository.find_by_fully_qualified_name(fully_qualified_name)

      return :scope_not_found if scope.nil?

      location_to_remove = scope.locations.find { |scope_location| scope_location.declaration.file.path == file_path }

      return :scope_not_defined_in_speciefied_file if location_to_remove.nil?

      scope.locations.delete(location_to_remove)

      location_to_remove.declaration.file.disconnect_scope(scope)

      if scope.locations.empty?
        scope.parent.children.delete(scope)

        repository.delete_by_fully_qualified_name(fully_qualified_name)
      else
        repository.store(scope)
      end

      :definition_unregistered
    end
  end
end
