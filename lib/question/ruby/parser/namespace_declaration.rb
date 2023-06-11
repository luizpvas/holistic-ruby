# frozen_string_literal: true

module Question::Ruby::Parser
  class NamespaceDeclaration
    attr_reader :value, :is_top_const_ref

    def initialize(value = [])
      @value = value
      @is_top_const_ref = false
    end

    # TODO: top_const_ref is a term inherited from the syntax_tree gem. I think I can come up with a more descriptive name.
    def mark_as_top_const_ref!
      @is_top_const_ref = true
    end

    def to_s
      is_top_const_ref ? "::#{@value.join("::")}" : @value.join("::")
    end

    def root_scope_resolution? = is_top_const_ref

    delegate :each, to: :value
    delegate :<<,   to: :value
  end
end
