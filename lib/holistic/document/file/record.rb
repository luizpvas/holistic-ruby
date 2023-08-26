# frozen_string_literal: true

module Holistic::Document::File
  class Record
    attr_reader :path

    def initialize(path:, adapter: Disk)
      @path = path
      @adapter = adapter
      @scopes = ::Set.new
    end

    def connect_scope(scope)
      @scopes.add(scope)
    end

    def disconnect_scope(scope)
      @scopes.delete(scope)
    end

    def read
      @adapter.read(self)
    end

    def write(content)
      @adapter.write(self, content)
    end
  end
end
