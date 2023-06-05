# frozen_string_literal: true

module Question::Ruby::Namespace
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

    def nest(kind:, name:, source_location:)
      append_source_location_to_existing_namespace(name:, source_location:) || add_new_namespace(kind:, name:, source_location:)
    end

    def root?
      parent.nil?
    end

    def delete(file_path)
      Delete.call(namespace: self, file_path: file_path)
    end

    private
      def append_source_location_to_existing_namespace(name:, source_location:)
        namespace = children.find { _1.name == name }

        return if namespace.nil?

        namespace.tap { _1.source_locations << source_location }
      end

      def add_new_namespace(kind:, name:, source_location:)
        namespace = self.class.new(kind:, name:, parent: self, source_location:)

        namespace.tap { children << _1 }
      end
  end
end
