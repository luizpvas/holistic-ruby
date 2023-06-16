# frozen_string_literal: true

module Holistic::Ruby::Application
  module Repository
    extend self

    AlreadyExistsError = ::Class.new(::StandardError)

    @items = {}

    def create(name:, root_directory:)
      raise AlreadyExistsError if @items.key?(name)

      application = Record.new(name:, root_directory:)

      @items[name] = application
    end

    def list_all   = @items.values

    def find(name) = @items.fetch(name)

    def delete_all = @items.clear
  end
end
