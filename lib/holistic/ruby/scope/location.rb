# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Location
    class Collection
      attr_reader :scope_name, :items

      def initialize(scope_name)
        @scope_name = scope_name
        @items = []
      end

      def main
        location_matching_scope_name || items.first
      end

      delegate :<<,      to: :items
      delegate :each,    to: :items
      delegate :find,    to: :items
      delegate :map,     to: :items
      delegate :delete,  to: :items
      delegate :any?,    to: :items
      delegate :empty?,  to: :items

      private

      def location_matching_scope_name
        scope_name_in_snake_case = scope_name.underscore

        items.find do |location|
          ::File.basename(location.declaration.file.attr(:path)) == "#{scope_name_in_snake_case}.rb"
        end
      end
    end

    attr_reader :declaration, :body

    def initialize(declaration:, body:)
      @declaration = declaration
      @body = body
    end
  end
end
