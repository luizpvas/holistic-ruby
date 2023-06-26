# frozen_string_literal: true

module Holistic::Ruby::Parser

  # TODO: Rename `NamespaceDeclaration` to something else. Probably should be the same name when we
  # figure out the new name for `Namespace::Record`

  class NamespaceDeclaration
    attr_reader :value, :is_root_scope

    def initialize(value = [])
      @value = value
      @is_root_scope = false
    end

    def mark_as_root_scope!
      @is_root_scope = true
    end

    def to_s
      @value.join("::")
    end

    def root_scope_resolution? = is_root_scope

    delegate :each, to: :value
    delegate :<<,   to: :value
  end
end
