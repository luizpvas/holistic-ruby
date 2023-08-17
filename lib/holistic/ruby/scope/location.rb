# frozen_string_literal: true

module Holistic::Ruby::Scope
  class Location
    class Collection
      attr_reader :scope, :items

      def initialize(scope, location)
        @scope = scope
        @items = location.nil? ? [] : [location]
      end

      def main
        location_matching_scope_name || items.first
      end

      delegate :<<,      to: :items
      delegate :each,    to: :items
      delegate :map,     to: :items
      delegate :reject!, to: :items
      delegate :any?,    to: :items

      private

      def location_matching_scope_name
        scope_name_in_snake_case = scope.name.underscore

        items.find do |location|
          ::File.basename(location.file_path) == "#{scope_name_in_snake_case}.rb"
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
