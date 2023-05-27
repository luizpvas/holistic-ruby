# frozen_string_literal: true

module Question::Ruby
  # TODO: Move to Application::Record
  class Application
    attr_reader :name, :root_directory, :root_namespace, :references

    def initialize(name:, root_directory:)
      @name = name
      @root_directory = root_directory
      @root_namespace = Namespace::Record.new(kind: :root, name: "::", parent: nil)
      @references = Constant::Repository::References.new
    end

    def symbol_index
      @symbol_index ||= Symbol::Index.new(application: self)
    end
  end
end
