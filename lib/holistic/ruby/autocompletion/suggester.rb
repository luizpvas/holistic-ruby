# frozen_string_literal: true

module Holistic::Ruby::Autocompletion
  module Suggester
    ResolveCrawler = ->(crawler, piece_of_code) do
      piece_of_code.namespaces.each do |namespace_name|
        constant = crawler.resolve_constant(namespace_name)

        return crawler if constant.nil?

        crawler = ::Holistic::Ruby::Scope::Crawler.new(scope: constant)
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
        overriden_by_subclass = ::Set.new

        sibling_methods = crawler.visible_scopes.filter { _1.kind == crawler.scope.kind }

        sibling_methods.each do |method_scope|
          next if overriden_by_subclass.include?(method_scope.name)

          if method_scope.name.start_with?(piece_of_code.word_to_autocomplete)
            suggestions << Suggestion.new(code: method_scope.name, kind: method_scope.kind)
            overriden_by_subclass.add(method_scope.name)
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
        overriden_by_subclass = ::Set.new

        crawler = ResolveCrawler.(crawler, piece_of_code)

        sibling_methods = crawler.visible_scopes.filter { _1.class_method? }

        sibling_methods.each do |method_scope|
          next if overriden_by_subclass.include?(method_scope.name)

          if method_scope.name.start_with?(piece_of_code.word_to_autocomplete)
            suggestions << Suggestion.new(code: method_scope.name, kind: method_scope.kind)
            overriden_by_subclass.add(method_scope.name)
          end
        end

        suggestions
      end
    end
  end
end
