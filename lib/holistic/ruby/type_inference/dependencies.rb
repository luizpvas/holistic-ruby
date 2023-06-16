# frozen_string_literal: true

module Holistic::Ruby::TypeInference
  class Dependencies
    attr_reader :application

    def initialize(application:)
      @application = application

      @from_dependency_to_dependants = ::Hash.new { |hash, key| hash[key] = ::Set.new }
    end

    def register(dependency_file_path:, dependant_identifier:)
      @from_dependency_to_dependants[dependency_file_path].add(dependant_identifier)
    end

    def delete_dependants(dependency_file_path:)
      @from_dependency_to_dependants[dependency_file_path].clear
    end

    def list_dependants(dependency_file_path:)
      @from_dependency_to_dependants[dependency_file_path].map { application.symbols.find(_1) }
    end
  end
end
