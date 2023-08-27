# frozen_string_literal: true

module Holistic::Document::File
  class Record
    attr_reader :path, :scopes, :references

    def initialize(path:)
      @path = path

      @scopes = ::Set.new
      @scopes.compare_by_identity

      @references = ::Set.new
      @references.compare_by_identity
    end

    def connect_scope(scope)
      @scopes.add(scope)
    end

    def disconnect_scope(scope)
      @scopes.delete(scope)
    end

    def connect_reference(reference)
      @references.add(reference)
    end

    def connected_to_reference?(reference)
      @references.include?(reference)
    end

    def disconnect_reference(reference)
      @references.delete(reference)
    end
  end
end
