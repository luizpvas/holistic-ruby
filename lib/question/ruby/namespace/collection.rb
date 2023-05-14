# frozen_string_literal: true

module Question::Ruby::Namespace
  class Collection
    def initialize(namespace)
      @items = {}

      build_index(namespace)
    end

    def find(name)
      return @items[""] if name == "::"

      @items[name]
    end

    private
      def build_index(namespace)
        @items[namespace.fully_qualified_name] = namespace

        namespace.children.each(&method(:build_index))
      end
  end
end
