# frozen_string_literal: true

module Holistic::Ruby::Parser
  class ConstantResolution
    attr_reader :scope_repository, :scope

    def initialize(scope_repository:, root_scope:)
      @scope_repository = scope_repository
      @scope = root_scope
      @constant_resolution_possibilities = ["::"]
    end

    def current
      @constant_resolution_possibilities.dup
    end

    def register_child_module(nesting:, location:, &block)
      starting_scope = @scope

      nesting.each do |name|
        @scope =
          ::Holistic::Ruby::Scope::Register.call(
            repository: @scope_repository,
            parent: @scope,
            kind: ::Holistic::Ruby::Scope::Kind::MODULE,
            name:,
            location:
          )
      end

      @constant_resolution_possibilities.unshift(@scope.fully_qualified_name)

      block.call

      @scope = starting_scope
      @constant_resolution_possibilities.shift
    end

    def register_child_class(nesting:, location:, &block)
      starting_scope = @scope

      nesting.each do |name|
        @scope =
          ::Holistic::Ruby::Scope::Register.call(
            repository: @scope_repository,
            parent: @scope,
            kind: ::Holistic::Ruby::Scope::Kind::CLASS,
            name:,
            location:
          )
      end

      @constant_resolution_possibilities.unshift(@scope.fully_qualified_name)

      block.call

      @scope = starting_scope
      @constant_resolution_possibilities.shift
    end
  end
end
