# frozen_string_literal: true

module Question::Ruby
  class Application
    attr_reader :repository

    def initialize
      @root = Constant::Namespace.new(kind: :root, name: "::", parent: nil)
      @repository = Constant::Repository.new(root: @root)
    end
  end
end
