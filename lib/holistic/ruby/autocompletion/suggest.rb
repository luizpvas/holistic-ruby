# frozen_string_literal: true

module Holistic::Ruby::Autocompletion
  module Suggest
    extend self

    Suggestion = ::Data.define(:code)

    def call(code:, scope:)
      lookup_scope = scope

      if code.start_with?("::")
        lookup_scope = lookup_scope.parent until lookup_scope.root?
      end

      suggest_namespaces_from_scope(code:, scope: lookup_scope)
    end

    private

    NonMethods = ->(scope) { !scope.method? }

    def suggest_namespaces_from_scope(code:, scope:)
      suggestions = []

      code_to_autocomplete_ends_in_double_colon = code.end_with?("::")

      partial_namespaces = code.split(/(::)/).compact_blank
      namespace_to_autocomplete = partial_namespaces.pop.then { _1 == "::" ? "" : _1 }
      namespace_to_autocomplete_ends_in_double_colon = namespace_to_autocomplete.end_with?("::")
      namespaces_to_resolve = partial_namespaces.reject { _1 == "::" }

      namespaces_to_resolve.each do |namespace_name|
        scope = resolve_scope(name: namespace_name, from_scope: scope)

        return suggestions if scope.nil?
      end

      # special case when user did not type :: at the end but the current word
      # is matches an existing namespace. In this case, suggestions will start with ::.
      # For example:
      #
      #                          \/ cursor here
      # typing: "::MyApp::Payments"
      # suggestions: ["::Record", "::SendReminder"]
      resolve_scope(name: namespace_to_autocomplete, from_scope: scope)&.then do |fully_typed_scope|
        scope = fully_typed_scope
        namespace_to_autocomplete = ""
      end

      should_search_upwards = namespaces_to_resolve.empty?

      search = ->(scope) do
        scope.children.filter(&NonMethods).each do |child_scope|
          if child_scope.name.start_with?(namespace_to_autocomplete)
            if code_to_autocomplete_ends_in_double_colon || !namespace_to_autocomplete.empty?
              suggestions << Suggestion.new(code: child_scope.name)
            else
              suggestions << Suggestion.new(code: "::#{child_scope.name}")
            end
          end
        end

        puts "scope: #{scope.fully_qualified_name} (#{scope.object_id})"

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
