# frozen_string_literal: true

module Holistic::Ruby::Scope
  module Delete
    extend self

    def call(database:, fully_qualified_name:, file_path:)
      scope = database.find(fully_qualified_name)

      return :scope_not_found if scope.nil?

      location_to_remove = scope.locations.find { |scope_location| scope_location.declaration.file.path == file_path }

      return :scope_not_defined_in_speciefied_file if location_to_remove.nil?

      scope.locations.delete(location_to_remove)

      scope.relation(:scope_defined_in_file).delete!(location_to_remove.declaration.file)

      if scope.locations.empty?
        scope.relation(:parent).delete!(scope.parent)

        database.delete(fully_qualified_name)
      end

      :definition_unregistered
    end
  end
end
