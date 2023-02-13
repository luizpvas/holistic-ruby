# frozen_string_literal: true

module Question::Ruby::Constant
  class Registry
    attr_reader :namespace, :references

    def initialize
      @namespace = Namespace::GLOBAL
      @references = []
    end

    def open_module(name, &block)
      @namespace = Namespace::Module.new(parent: namespace, name:)

      block.call

      @namespace = @namespace.parent
    end

    def add_reference!(name)
      references << Reference.new(namespace:, name:)
    end
  end
end
