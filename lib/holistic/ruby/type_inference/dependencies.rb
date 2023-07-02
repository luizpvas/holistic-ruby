# frozen_string_literal: true

module Holistic::Ruby::TypeInference
  class Dependencies
    attr_reader :application

    def initialize(application:)
      @application = application

      @from_dependency_to_references = ::Hash.new { |hash, key| hash[key] = ::Set.new }
      @from_dependency_file_path_to_references = ::Hash.new { |hash, key| hash[key] = ::Set.new }
    end

    def register(dependency:, reference_identifier:)
      raise ::ArgumentError, "#{dependency.inspect} must be a Symbol" unless dependency.is_a?(::Holistic::Ruby::Symbol::Record)

      @from_dependency_to_references[dependency.identifier].add(reference_identifier)

      dependency.locations.each do |location|
        @from_dependency_file_path_to_references[location.file_path].add(reference_identifier)
      end
    end

    def delete_references(dependency_file_path:)
      application.symbols.list_symbols_in_file(dependency_file_path).each do |dependency|
        @from_dependency_to_references[dependency.identifier].clear
      end

      references = @from_dependency_file_path_to_references[dependency_file_path].to_a

      @from_dependency_file_path_to_references[dependency_file_path].clear

      references.map { application.symbols.find(_1) }
    end

    def list_references(dependency_file_path: nil, dependency_identifier: nil)
      if dependency_file_path.present?
        return @from_dependency_file_path_to_references[dependency_file_path].map { application.symbols.find(_1) }
      end

      if dependency_identifier.present?
        return @from_dependency_to_references[dependency_identifier].map { application.symbols.find(_1) }
      end

      raise ::ArgumentError, "either :dependency_file_path or :dependency_identifier must be specified"
    end
  end
end
