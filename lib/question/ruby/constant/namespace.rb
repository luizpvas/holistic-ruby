# frozen_string_literal: true

module Question::Ruby::Constant
  class Namespace
    attr_reader :kind, :name, :parent, :children, :source_locations

    def initialize(kind:, name:, parent:, source_location: nil)
      @kind = kind
      @parent = parent
      @name = name
      @source_locations = source_location.nil? ? [] : [source_location]
      @children = []
    end

    def nest(kind:, name:, source_location:)
      children.find { _1.name == name }&.then do |namespace|
        namespace.source_locations << source_location

        return namespace
      end

      self.class.new(kind: kind, name: name, parent: self, source_location:).tap { children << _1 }
    end

    def root? = parent.nil?
  end
end
