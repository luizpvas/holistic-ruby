# frozen_string_literal: true

module Question::Ruby
  module Application::Repository
    extend self

    AlreadyExistsError = ::Class.new(::StandardError)

    @items = {}

    def create(name:, root_directory:)
      raise AlreadyExistsError if @items.key?(name)

      application = Application.new(root_directory:)

      @items[name] = application
    end

    def delete_all = @items.clear
  end
end
