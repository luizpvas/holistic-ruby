# frozen_string_literal: true

module Holistic::Ruby::Scope
  module Unregister
    extend self

    def call(repository:, fully_qualified_name:, file_path:)
      scope = repository.find(fully_qualified_name)

      return :scope_not_found if scope.nil?

      location_to_remove = scope.attr(:locations).find { |scope_location| scope_location.declaration.file.attr(:path) == file_path }

      return :scope_not_defined_in_speciefied_file if location_to_remove.nil?

      scope.attr(:locations).delete(location_to_remove)

      repository.database.disconnect(source: location_to_remove.declaration.file, target: scope, name: :defines_scopes, inverse_of: :scope_defined_in_file)

      if scope.attr(:locations).empty?
        repository.database.disconnect(source: scope.has_one(:parent), target: scope, name: :children, inverse_of: :parent)

        repository.delete_by_fully_qualified_name(fully_qualified_name)
      end

      :definition_unregistered
    end
  end
end
