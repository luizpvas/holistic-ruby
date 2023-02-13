# frozen_string_literal: true

module Question::Ruby::Constant
  class Registry
    attr_reader :namespace

    def initialize
      @namespace = Namespace::GLOBAL
    end

    def open!(&block)
      @namespace = block.call(namespace)
    end

    CannotCloseGlobalNamespaceError = ::Class.new(::StandardError)

    def close!
      raise CannotCloseGlobalNamespaceError if namespace.global?

      @namespace = namespace.parent_namespace
    end
  end
end
