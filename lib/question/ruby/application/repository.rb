# frozen_string_literal: true

module Question::Ruby
  module Application::Repository
    extend self

    AlreadyExistsError = ::Class.new(::StandardError)

    @items = {}

    def create(name:, root_directory:)
      raise AlreadyExistsError if @items.key?(name)

      application = Application.new(name:, root_directory:)

      @items[name] = application
    end

    def list_all   = @items.values

    def find(name) = @items.fetch(name)

    def delete_all = @items.clear
  end
end
