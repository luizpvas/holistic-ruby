# frozen_string_literal: true

module Holistic::Ruby::TypeInference
  # Why track `from_dependency_to_dependants`?
  #
  # So that we can provide the `Go to reference` in the language server protocol.
  #
  # Why track `from_dependency_file_path_to_dependants`?
  #
  # Because of live editing. We need to know what to recalculate when a file changes.
  class Dependencies
    attr_reader :application

    def initialize(application:)
      @application = application

      @from_dependency_to_dependants = ::Hash.new { |hash, key| hash[key] = ::Set.new }
      @from_dependency_file_path_to_dependants = ::Hash.new { |hash, key| hash[key] = ::Set.new }
    end

    def register(dependency:, dependant_identifier:)
      raise ::ArgumentError, "#{dependency.inspect} must be a Symbol" unless dependency.is_a?(::Holistic::Ruby::Symbol::Record)

      @from_dependency_to_dependants[dependency.identifier].add(dependant_identifier)

      dependency.source_locations.each do |source_location|
        @from_dependency_file_path_to_dependants[source_location.file_path].add(dependant_identifier)
      end
    end

    def delete_dependants(dependency_file_path:)
      application.symbols.list_symbols_in_file(dependency_file_path).each do |dependency|
        @from_dependency_to_dependants[dependency.identifier].clear
      end

      dependants = @from_dependency_file_path_to_dependants[dependency_file_path].to_a

      @from_dependency_file_path_to_dependants[dependency_file_path].clear

      dependants.map { application.symbols.find(_1) }
    end

    def list_dependants(dependency_file_path:)
      @from_dependency_file_path_to_dependants[dependency_file_path].map { application.symbols.find(_1) }
    end
  end
end
