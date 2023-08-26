# frozen_string_literal: true

module Holistic::Document::File
  class Record
    attr_reader :path, :scopes

    def initialize(path:)
      @path = path
      @scopes = ::Set.new
    end

    def connect_scope(scope)
      @scopes.add(scope)
    end

    def disconnect_scope(scope)
      @scopes.delete(scope)
    end
  end
end
