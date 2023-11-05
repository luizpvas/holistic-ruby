# frozen_string_literal: true

module Holistic::Ruby::Autocompletion
  module Suggester
    ResolveCrawler = ->(crawler, piece_of_code) do
      piece_of_code.namespaces.each do |namespace_name|
        constant = crawler.resolve_constant(namespace_name)

        return crawler if constant.nil?

        crawler = ::Holistic::Ruby::Scope::Crawler.new(application: crawler.application, scope: constant)
      end

      crawler
    end

    class Everything
      def initialize(piece_of_code)
        @piece_of_code = piece_of_code
      end

      def suggest(crawler:)
        raise "todo"
      end
    end

    class Constants
      attr_reader :piece_of_code

      def initialize(piece_of_code)
        @piece_of_code = piece_of_code
      end

      def suggest(crawler:)
        suggestions = []

        crawler = ResolveCrawler.(crawler, piece_of_code)

        lookup_scopes =
          if piece_of_code.namespaces.any?
            [crawler.scope]
          else
            crawler.lexical_parents
          end

        lookup_scopes.each do |scope|
          scope.lexical_children.each do |child_scope|
            next if child_scope.method?

            if child_scope.name.start_with?(piece_of_code.word_to_autocomplete)
              suggestions << Suggestion.new(code: child_scope.name, kind: child_scope.kind)
            end
          end
        end

        suggestions
      end
    end

    class MethodsFromCurrentScope
      attr_reader :piece_of_code

      def initialize(piece_of_code)
        @piece_of_code = piece_of_code
      end

      def suggest(crawler:)
        suggestions = []

        scope = crawler.scope

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

      def suggest(crawler:)
        suggestions = []

        crawler = ResolveCrawler.(crawler, piece_of_code)

        class_methods = ::Holistic::Ruby::Scope::ListClassMethods.call(scope: crawler.scope)

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
