# frozen_string_literal: true

module Holistic::Ruby::TypeInference
  class Dependencies
    attr_reader :application

    def initialize(application:)
      @application = application

      @from_scope_to_references = ::Hash.new { |hash, key| hash[key] = ::Set.new }

      # TODO: do we really need this index? Can we just call `application.scopes.list_scopes_in_file` to get the scopes,
      # and then look for references in `from_scope_to_references` and delete them?
      @from_scope_file_path_to_references = ::Hash.new { |hash, key| hash[key] = ::Set.new }
    end

    def register(dependency:, reference_identifier:)
      raise ::ArgumentError, "#{dependency.inspect} must be a Scope" unless dependency.is_a?(::Holistic::Ruby::Scope::Record)

      @from_scope_to_references[dependency.fully_qualified_name].add(reference_identifier)

      dependency.locations.each do |location|
        @from_scope_file_path_to_references[location.file_path].add(reference_identifier)
      end
    end

    def delete_references(scope_file_path:)
      application.symbols.list_symbols_in_file(scope_file_path).each do |dependency|
        @from_scope_to_references[dependency.identifier].clear
      end

      references = @from_scope_file_path_to_references[scope_file_path].to_a

      @from_scope_file_path_to_references[scope_file_path].clear

      references.map { application.symbols.find(_1) }
    end

    # TODO: do we really need it?
    def list_references(dependency_file_path: nil, dependency_identifier: nil)
      if dependency_file_path.present?
        return @from_scope_file_path_to_references[dependency_file_path].map { application.references.find(_1) }
      end

      if dependency_identifier.present?
        return @from_scope_to_references[dependency_identifier].map { application.symbols.find(_1) }
      end

      raise ::ArgumentError, "either :dependency_file_path or :dependency_identifier must be specified"
    end
  end
end
