# frozen_string_literal: true

module Holistic::Ruby::Parser
  class Expression
    attr_reader :value, :is_root_scope

    def self.build(node)
      expression = Expression.new

      append = ->(node) do
        case node
        when ::SyntaxTree::ConstRef     then expression << node.child_nodes[0].value
        when ::SyntaxTree::VarField     then expression << node.child_nodes.first.value
        when ::SyntaxTree::Const        then expression << node.value
        when ::SyntaxTree::VCall        then append.(node.child_nodes.first)
        when ::SyntaxTree::Ident        then expression << node.value
        when ::SyntaxTree::Kw           then expression << node.value
        when ::SyntaxTree::IVar         then expression << node.value
        when ::SyntaxTree::Period       then expression << "."
        when ::SyntaxTree::Paren        then append.(node.child_nodes[1])       # node.child_nodes[0] is ::SyntaxTree::LParen
        when ::SyntaxTree::ARef         then append.(node.child_nodes.first)    # not sure what to do here e.g. `ActiveRecord::Migration[7.0]`
        when ::SyntaxTree::CallNode     then node.child_nodes.each(&append)
        when ::SyntaxTree::IfOp         then expression << "[conditional]"  # not sure what tod o here
        when ::SyntaxTree::VarRef       then node.child_nodes.each(&append)
        when ::SyntaxTree::ConstPathRef then node.child_nodes.each(&append)
        when ::SyntaxTree::Statements   then node.child_nodes.each(&append)
        when ::SyntaxTree::TopConstRef  then expression.mark_as_root_scope! and node.child_nodes.each(&append)
        # else pp(original_node) and pp(Current.file.path) and raise "Unexpected node type: #{node.class}"
        end
      end

      append.(node)

      expression
    end

    def initialize(value = [])
      @value = Array(value)
      @is_root_scope = false
    end

    def mark_as_root_scope!
      @is_root_scope = true
    end

    def supported?
      @value.any?
    end

    def unsupported?
      !supported?
    end

    def root_scope_resolution?
      is_root_scope
    end

    def constant?
      return false if unsupported?

      @value.last[0].then { _1 == _1.upcase }
    end

    def to_s
      @value.join("::")
    end

    def eql?(other)
      other.class == self.class && other.to_s == to_s
    end

    alias == eql?

    delegate :each, to: :value
    delegate :<<,   to: :value
  end
end