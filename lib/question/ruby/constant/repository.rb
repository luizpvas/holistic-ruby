# frozen_string_literal: true

module Question::Ruby::Constant
  class Repository
    attr_reader :namespace, :references

    def initialize(root:)
      @namespace = root
      @references = []
    end

    def open_module(name, &block)
      @namespace = @namespace.nest(kind: :module, name:)

      block.call

      @namespace = @namespace.parent
    end

    def open_class(name, &block)
      @namespace = @namespace.nest(kind: :class, name:)

      block.call

      @namespace = @namespace.parent
    end

    def add_reference!(name)
      references << Reference.new(namespace:, name:)
    end
  end
end
