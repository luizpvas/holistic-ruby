# frozen_string_literal: true

module Holistic::Ruby::Autocompletion
  module Suggest
    extend self

    Suggestion = ::Data.define(:code, :kind)

    def call(piece_of_code:, scope:)
      lookup_scope = scope

      if piece_of_code.root_scope?
        lookup_scope = lookup_scope.lexical_parent until lookup_scope.root?
      end

      case piece_of_code.kind
      when :suggest_methods_from_current_scope
        suggest_local_methods_from_current_scope(code: piece_of_code.value, scope: lookup_scope)
      when :suggest_methods_from_scope
        suggest_methods_from_scope(code: piece_of_code.value, scope: lookup_scope)
      when :suggest_namespaces
        suggest_namespaces(code: piece_of_code.value, scope: lookup_scope)
      else
        ::Holistic.logger.info("unknown code kind: #{piece_of_code}")

        []
      end
    end

    private

    def suggest_local_methods_from_current_scope(code:, scope:)
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
        if method_scope.name.start_with?(code)
          suggestions << Suggestion.new(code: method_scope.name, kind: method_scope.kind)
        end
      end

      suggestions
    end

    def suggest_methods_from_scope(code:, scope:)
      suggestions = []

      partial_namespaces = code.split(/(::|\.)/).compact_blank
      method_to_autocomplete = partial_namespaces.pop.then { _1 == "." ? "" : _1 }
      namespaces_to_resolve = partial_namespaces.reject { _1 == "::" || _1 == "." }

      namespaces_to_resolve.each do |namespace_name|
        scope = resolve_scope(name: namespace_name, from_scope: scope)

        return suggestions if scope.nil?
      end

      class_methods = ::Holistic::Ruby::Scope::ListClassMethods.call(scope:)

      class_methods.each do |method_scope|
        if method_scope.name.start_with?(method_to_autocomplete)
          suggestions << Suggestion.new(code: method_scope.name, kind: method_scope.kind)
        end
      end

      suggestions
    end

    def suggest_namespaces(code:, scope:)
      suggestions = []

      partial_namespaces = code.split(/(::)/).compact_blank
      namespace_to_autocomplete = partial_namespaces.pop.then { _1 == "::" ? "" : _1 }
      namespaces_to_resolve = partial_namespaces.reject { _1 == "::" }

      namespaces_to_resolve.each do |namespace_name|
        scope = resolve_scope(name: namespace_name, from_scope: scope)

        return suggestions if scope.nil?
      end

      should_search_upwards = namespaces_to_resolve.empty?

      search = ->(scope) do
        scope.lexical_children.each do |child_scope|
          next if child_scope.method?

          if child_scope.name.start_with?(namespace_to_autocomplete)
            suggestions << Suggestion.new(code: child_scope.name, kind: child_scope.kind)
          end
        end

        search.(scope.lexical_parent) if scope.lexical_parent.present? && should_search_upwards
      end

      search.(scope)

      suggestions
    end

    def resolve_scope(name:, from_scope:)
      resolved_scope = from_scope.lexical_children.find { |scope| scope.name == name }

      if resolved_scope.nil? && from_scope.lexical_parent.present?
        resolved_scope = resolve_scope(name:, from_scope: from_scope.lexical_parent)
      end

      resolved_scope
    end
  end
end
