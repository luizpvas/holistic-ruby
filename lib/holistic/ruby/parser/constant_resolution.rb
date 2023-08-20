# frozen_string_literal: true

module Holistic::Ruby::Parser
  class ConstantResolution
    module MethodRegistrationMode
      INSTANCE_METHODS = :instance_methods
      CLASS_METHODS    = :class_methods
    end

    attr_reader :scope_repository, :scope, :method_registration_mode

    def initialize(scope_repository:, root_scope:)
      @scope_repository = scope_repository
      @scope = root_scope
      @constant_resolution_possibilities = ["::"]
      @method_registration_mode = MethodRegistrationMode::INSTANCE_METHODS
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

      registered_module_scope = @scope

      @constant_resolution_possibilities.unshift(@scope.fully_qualified_name)

      block.call

      change_method_registration_mode_to_instance_methods!
      @constant_resolution_possibilities.shift
      @scope = starting_scope

      registered_module_scope
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

      registered_class_scope = @scope

      @constant_resolution_possibilities.unshift(@scope.fully_qualified_name)

      block.call

      change_method_registration_mode_to_instance_methods!
      @constant_resolution_possibilities.shift
      @scope = starting_scope

      registered_class_scope
    end

    def register_child_method(nesting:, location:, kind:, &block)
      starting_scope = @scope

      nesting.each do |name|
        @scope =
          ::Holistic::Ruby::Scope::Register.call(
            repository: @scope_repository,
            parent: @scope,
            kind:,
            name:,
            location:
          )
      end

      registered_method_scope = @scope

      block.call

      @scope = starting_scope

      registered_method_scope
    end

    def method_registration_class_methods?
      method_registration_mode == MethodRegistrationMode::CLASS_METHODS
    end

    def change_method_registration_mode_to_class_methods!
      @method_registration_mode = MethodRegistrationMode::CLASS_METHODS
    end

    def change_method_registration_mode_to_instance_methods!
      @method_registration_mode = MethodRegistrationMode::INSTANCE_METHODS
    end
  end
end
