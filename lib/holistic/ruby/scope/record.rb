# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Record
    attr_reader :kind, :name, :parent, :children, :locations

    def initialize(kind:, name:, parent:, location: nil)
      @kind = kind
      @name = name
      @parent = parent
      @locations = location.nil? ? [] : [location]
      @children = []
    end

    # NOTE: I don't like having this serialize here. It feels weird.
    def serialize
      nested = {}
      root = {name => nested}

      children.each do |child|
        nested.merge!(child.serialize)
      end

      root
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

    def main_location
      FindMainLocation.call(scope: self)
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
