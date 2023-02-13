# frozen_string_literal: true

module Question::Ruby::Constant
  class Registry
    attr_reader :namespace, :references

    def initialize
      @namespace = Namespace::GLOBAL
      @references = []
    end

    def open!(&block)
      @namespace = block.call(namespace)
    end

    def close!
      raise "Cannot close global namespace" if namespace.global?

      @namespace = namespace.parent_namespace
    end

    def add_reference!(&block)
      references << block.call(namespace)
    end
  end
end
