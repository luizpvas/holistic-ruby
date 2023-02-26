# frozen_string_literal: true

module Question::Ruby::Constant
  class Namespace
    attr_reader :kind, :name, :parent, :children, :source_locations

    def initialize(kind:, name:, parent:)
      @kind = kind
      @parent = parent
      @name = name
      @source_locations = []
      @children = []
    end

    def nest(kind:, name:)
      namespace = children.find { _1.name == name }

      return namespace if namespace

      self.class.new(kind: kind, name: name, parent: self).tap { children << _1 }
    end

    def root? = parent.nil?
  end
end
