# frozen_string_literal: true

module Question::Ruby
  class Application
    attr_reader :root_directory, :repository

    def initialize(root_directory:)
      @root_directory = root_directory
      @root = Constant::Namespace.new(kind: :root, name: "::", parent: nil)
      @repository = Constant::Repository.new(root: @root)
    end
  end
end
