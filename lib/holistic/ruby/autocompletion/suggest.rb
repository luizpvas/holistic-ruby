# frozen_string_literal: true

module Holistic::Ruby::Autocompletion
  module Suggest
    extend self

    Suggestion = ::Data.define(:code, :kind)

    StartsWithLowerCaseLetter = ->(code) do
      return false if [".", ":", "@"].include?(code[0])

      code[0] == code[0].downcase
    end

    def call(code:, scope:)
      lookup_scope = scope

      if code.start_with?("::")
        lookup_scope = lookup_scope.parent until lookup_scope.kind == ::Holistic::Ruby::Scope::Kind::ROOT
      end

      if StartsWithLowerCaseLetter[code]
        suggest_local_methods_from_current_scope(code:, scope: lookup_scope)
      elsif code.include?(".")
        suggest_methods_from_scope(code:, scope: lookup_scope)
      else
        suggest_namespaces_from_scope(code:, scope: lookup_scope)
      end
    end

    private

    def suggest_local_methods_from_current_scope(code:, scope:)
      suggestions = []

      method_to_autocomplete = code

      if scope.kind == ::Holistic::Ruby::Scope::Kind::INSTANCE_METHOD
        sibling_methods = scope.parent.children.filter { _1.kind == ::Holistic::Ruby::Scope::Kind::INSTANCE_METHOD }

        sibling_methods.each do |method_scope|
          if method_scope.name.start_with?(method_to_autocomplete)
            suggestions << Suggestion.new(code: method_scope.name, kind: method_scope.kind)
          end
        end
      elsif scope.kind == ::Holistic::Ruby::Scope::Kind::CLASS_METHOD
        sibling_methods = scope.parent.children.filter { _1.kind == ::Holistic::Ruby::Scope::Kind::CLASS_METHOD }

        sibling_methods.each do |method_scope|
          if method_scope.name.start_with?(method_to_autocomplete)
            suggestions << Suggestion.new(code: method_scope.name, kind: method_scope.kind)
          end
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

      class_methods = scope.children.filter { _1.kind == ::Holistic::Ruby::Scope::Kind::CLASS_METHOD }

      class_methods.each do |method_scope|
        if method_scope.name.start_with?(method_to_autocomplete)
          suggestions << Suggestion.new(code: method_scope.name, kind: method_scope.kind)
        end
      end

      suggestions
    end

    def suggest_namespaces_from_scope(code:, scope:)
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
        scope.children.each do |child_scope|
          next if child_scope.kind == ::Holistic::Ruby::Scope::Kind::CLASS_METHOD || child_scope.kind == ::Holistic::Ruby::Scope::Kind::INSTANCE_METHOD

          if child_scope.name.start_with?(namespace_to_autocomplete)
            suggestions << Suggestion.new(code: child_scope.name, kind: child_scope.kind)
          end
        end

        search.(scope.parent) if scope.parent.present? && should_search_upwards
      end

      search.(scope)

      suggestions
    end

    def resolve_scope(name:, from_scope:)
      resolved_scope = from_scope.children.find { |scope| scope.name == name }

      if resolved_scope.nil? && from_scope.parent.present?
        resolved_scope = resolve_scope(name:, from_scope: from_scope.parent)
      end

      resolved_scope
    end
  end
end
