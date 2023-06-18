# frozen_string_literal: true

module Holistic::Ruby::Namespace
  class Record
    attr_reader :kind, :name, :parent, :children, :source_locations

    def initialize(kind:, name:, parent:, source_location: nil)
      @kind = kind
      @parent = parent
      @name = name
      @source_locations = source_location.nil? ? [] : [source_location]
      @children = []
    end

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

      "#{parent.fully_qualified_name}::#{name}"
    end

    def root?
      parent.nil?
    end

    def descendant?(other)
      parent.present? && (parent == other || parent.descendant?(other))
    end

    def namespace
      self
    end

    def delete(file_path)
      Delete.call(namespace: self, file_path: file_path)
    end
  end
end
