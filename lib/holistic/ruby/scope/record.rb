# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Record
    attr_reader :kind, :name, :parent, :children, :locations

    def initialize(kind:, name:, parent:, location: nil)
      @kind = kind
      @name = name
      @parent = parent
      @locations = Location::Collection.new(self, location)
      @children = []
    end

    def fully_qualified_name
      return "" if root?

      separator =
        if kind == Kind::METHOD
          "#"
        else
          "::"
        end

      "#{parent.fully_qualified_name}#{separator}#{name}"
    end

    def root?
      parent.nil?
    end

    def lambda?
      kind == Kind::LAMBDA
    end

    def class?
      kind == Kind::CLASS
    end

    def module?
      kind == Kind::MODULE
    end

    def descendant?(other)
      parent.present? && (parent == other || parent.descendant?(other))
    end
  end
end
