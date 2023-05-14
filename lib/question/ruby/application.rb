# frozen_string_literal: true

module Question::Ruby
  class Application
    attr_reader :root_directory, :root_namespace, :repository

    def initialize(root_directory:)
      @root_directory = root_directory
      @root_namespace = Namespace::Record.new(kind: :root, name: "::", parent: nil)
      @repository = Constant::Repository.new
    end
  end
end
