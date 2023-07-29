# frozen_string_literal: true

module Holistic::Ruby::Scope
  module ResolveConstant
    extend self

    Root = ->(scope) do
      scope = scope.parent until scope.parent.root?

      scope
    end

    Resolve = ->(scope, name) do
      return if scope.nil?

      scope.children.find { _1.name == name } || Resolve[scope.parent, name]
    end

    def call(scope:, constant_nesting_syntax:)
      resolved_scope = constant_nesting_syntax.root_scope_resolution? ? Root[scope] : scope
      constant_names = constant_nesting_syntax.value.dup

      while !constant_names.empty?
        name_to_resolve = constant_names.shift

        resolved_scope = Resolve[resolved_scope, name_to_resolve]

        return nil if resolved_scope.blank?
      end

      resolved_scope
    end
  end
end
