# frozen_string_literal: true

module Holistic::Ruby::Autocompletion
  module Suggester
    ResolveCrawler = ->(crawler, expression) do
      expression.namespaces.each do |namespace_name|
        constant = crawler.resolve_constant(namespace_name)

        return crawler if constant.nil?

        crawler = constant.crawler
      end

      crawler
    end

    class Everything
      def initialize(expression)
        @expression = expression
      end

      def suggest(scope:)
        raise "todo"
      end
    end

    class Constants
      attr_reader :expression

      def initialize(expression)
        @expression = expression
      end

      def suggest(scope:)
        suggestions = []

        has_at_least_one_completed_namespace =
          expression.namespaces.length > 1 ||
          expression.namespaces.one? && expression.namespaces.first != expression.last_subexpression

        lookup_scopes =
          if has_at_least_one_completed_namespace
            [ResolveCrawler.(scope.crawler, expression).scope]
          else
            scope.crawler.lexical_parents
          end

        lookup_scopes.each do |scope|
          scope.lexical_children.each do |child_scope|
            next if child_scope.method?

            if child_scope.name.start_with?(expression.last_subexpression)
              suggestions << Suggestion.new(code: child_scope.name, kind: child_scope.kind)
            end
          end
        end

        suggestions
      end
    end

    class MethodsFromCurrentScope
      attr_reader :expression

      def initialize(expression)
        @expression = expression
      end

      def suggest(scope:)
        suggestions = []
        overriden_by_subclass = ::Set.new

        sibling_methods = scope.crawler.visible_scopes.filter { _1.kind == scope.kind }

        sibling_methods.each do |method_scope|
          next if overriden_by_subclass.include?(method_scope.name)

          if method_scope.name.start_with?(expression.last_subexpression)
            suggestions << Suggestion.new(code: method_scope.name, kind: method_scope.kind)
            overriden_by_subclass.add(method_scope.name)
          end
        end

        suggestions
      end
    end

    class MethodsFromScope
      attr_reader :expression

      def initialize(expression)
        @expression = expression
      end

      def suggest(scope:)
        suggestions = []
        overriden_by_subclass = ::Set.new

        crawler = ResolveCrawler.(scope.crawler, expression)

        sibling_methods = crawler.visible_scopes.filter { _1.class_method? }

        sibling_methods.each do |method_scope|
          next if overriden_by_subclass.include?(method_scope.name)

          if method_scope.name.start_with?(expression.last_subexpression)
            suggestions << Suggestion.new(code: method_scope.name, kind: method_scope.kind)
            overriden_by_subclass.add(method_scope.name)
          end
        end

        suggestions
      end
    end

    def self.for(expression:)
      if expression.empty?
        return Everything.new(expression)
      end

      if expression.starts_with_lower_case_letter? || (expression.looks_like_method_call? && !expression.has_dot?)
        return MethodsFromCurrentScope.new(expression)
      end

      if expression.has_dot?
        return MethodsFromScope.new(expression)
      end

      Constants.new(expression)
    end
  end
end
