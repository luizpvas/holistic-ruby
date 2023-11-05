# frozen_string_literal: true

module Holistic::Ruby::Autocompletion
  module Suggester
    ResolveScope = ->(name:, from_scope:) do
      resolved_scope = from_scope.lexical_children.find { |scope| scope.name == name }

      if resolved_scope.nil? && from_scope.lexical_parent.present?
        resolved_scope = ResolveScope.(name:, from_scope: from_scope.lexical_parent)
      end

      resolved_scope
    end

    class Everything
      def initialize(piece_of_code)
        @piece_of_code = piece_of_code
      end

      def suggest(scope:)
        raise "todo"
      end
    end

    class Constants
      attr_reader :piece_of_code

      def initialize(piece_of_code)
        @piece_of_code = piece_of_code
      end

      def suggest(scope:)
        suggestions = []

        piece_of_code.namespaces.each do |namespace_name|
          scope = ResolveScope.(name: namespace_name, from_scope: scope)

          return suggestions if scope.nil?
        end

        should_search_upwards = piece_of_code.namespaces.empty?

        search = ->(scope) do
          scope.lexical_children.each do |child_scope|
            next if child_scope.method?

            if child_scope.name.start_with?(piece_of_code.word_to_autocomplete)
              suggestions << Suggestion.new(code: child_scope.name, kind: child_scope.kind)
            end
          end

          search.(scope.lexical_parent) if scope.lexical_parent.present? && should_search_upwards
        end

        search.(scope)

        suggestions
      end
    end

    class MethodsFromCurrentScope
      attr_reader :piece_of_code

      def initialize(piece_of_code)
        @piece_of_code = piece_of_code
      end

      def suggest(scope:)
        suggestions = []

        sibling_methods =
          case scope.kind
          when ::Holistic::Ruby::Scope::Kind::CLASS_METHOD
            ::Holistic::Ruby::Scope::ListClassMethods.call(scope: scope.lexical_parent)
          when ::Holistic::Ruby::Scope::Kind::INSTANCE_METHOD
            ::Holistic::Ruby::Scope::ListInstanceMethods.call(scope: scope.lexical_parent)
          else
            # TODO: global functions?

            return []
          end

        sibling_methods.each do |method_scope|
          if method_scope.name.start_with?(piece_of_code.word_to_autocomplete)
            suggestions << Suggestion.new(code: method_scope.name, kind: method_scope.kind)
          end
        end

        suggestions
      end
    end

    class MethodsFromScope
      attr_reader :piece_of_code

      def initialize(piece_of_code)
        @piece_of_code = piece_of_code
      end

      def suggest(scope:)
        suggestions = []

        piece_of_code.namespaces.each do |namespace_name|
          scope = ResolveScope.(name: namespace_name, from_scope: scope)

          return suggestions if scope.nil?
        end

        class_methods = ::Holistic::Ruby::Scope::ListClassMethods.call(scope:)

        class_methods.each do |method_scope|
          if method_scope.name.start_with?(piece_of_code.word_to_autocomplete)
            suggestions << Suggestion.new(code: method_scope.name, kind: method_scope.kind)
          end
        end

        suggestions
      end
    end
  end
end
